import AppKit
import CoreGraphics
import IOKit.pwr_mgt
import SessionKit

/// Short, opt-in native probe; creates and cleans only this process's assertions.
/// No curtain, credentials, preference writes, forced sleep or user-activity synthesis.
@MainActor
enum EnergyRuntimeProbe {
    static func run(directory: URL) async {
        let driver = IOKitAssertionDriver()
        let clock = SessionClock()
        let energy = EnergySession(driver: driver, now: { clock.now })
        let curtain = CurtainAwakeSession(driver: driver)
        var checks: [String: Bool] = [:]
        var states: [[String: Any]] = []
        var kernelID: UInt32?
        defer {
            curtain.setCovered(false)
            energy.stop()
            if let kernelID { _ = driver.release(kernelID) }
        }

        func snapshot(_ phase: String) throws {
            let assertions: [[String: Any]] = energy.owned.map { kind, id in
                let properties = driver.properties(id)
                return [
                    "kind": kind.rawValue,
                    "id": id,
                    "active": driver.isActive(id),
                    "name": properties?[kIOPMAssertionNameKey] as? String ?? "missing",
                    "timeoutSeconds": properties?[kIOPMAssertionTimeoutKey] as? NSNumber ?? 0,
                ]
            }
            states.append(["phase": phase, "running": energy.isRunning, "remainingSeconds": energy.remaining, "assertions": assertions])
            try write(["phase": phase, "pid": ProcessInfo.processInfo.processIdentifier], to: "progress.json")
        }

        func write(_ object: [String: Any], to name: String) throws {
            let data = try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys, .prettyPrinted])
            try data.write(to: directory.appendingPathComponent(name), options: .atomic)
        }

        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            curtain.setCovered(true)
            guard let curtainID = curtain.owned else { throw EnergyFailure(code: "PROBE_CURTAIN_MISSING", message: "No curtain assertion returned") }
            checks["curtainDisplayRequestHasNoTimeout"] = driver.isActive(curtainID) && ((driver.properties(curtainID)?[kIOPMAssertionTimeoutKey] as? NSNumber)?.doubleValue ?? 0) == 0
            checks["curtainUsesDisplayAssertion"] = (driver.properties(curtainID)?[kIOPMAssertionTypeKey] as? String) == (kIOPMAssertionTypePreventUserIdleDisplaySleep as String)
            curtain.setCovered(true)
            checks["curtainRebuildPreservesID"] = curtain.owned == curtainID
            curtain.setCovered(false)
            checks["curtainReturnReleasesRequest"] = driver.properties(curtainID) == nil
            curtain.setCovered(true)
            let resumedID = curtain.owned
            checks["curtainResumeAcquiresRequest"] = resumedID.map { driver.isActive($0) } ?? false
            curtain.setCovered(false)
            checks["curtainSuspendReleasesRequest"] = resumedID.map { driver.properties($0) == nil } ?? false
            checks["startsWithNoAssertions"] = energy.owned.isEmpty
            try energy.start(seconds: 6).get()
            guard let systemID = energy.owned[.system] else { throw EnergyFailure(code: "PROBE_SYSTEM_MISSING", message: "No system assertion returned") }
            checks["systemOnlyAcquired"] = driver.isActive(systemID) && energy.owned[.display] == nil
            try snapshot("system-only")
            try await Task.sleep(for: .seconds(1.2))
            try energy.setKeepDisplaysOn(true).get()
            guard let displayID = energy.owned[.display] else { throw EnergyFailure(code: "PROBE_DISPLAY_MISSING", message: "No display assertion returned") }
            checks["displayAcquiredIndependently"] = driver.isActive(displayID) && energy.owned[.system] == systemID
            try snapshot("system-and-display")
            try await Task.sleep(for: .seconds(1.2))
            try energy.setKeepDisplaysOn(false).get()
            checks["displayStopPreservesSystem"] = driver.properties(displayID) == nil && driver.isActive(systemID)
            try snapshot("display-stopped")
            energy.stop()
            checks["manualStopReleasesSystem"] = energy.owned.isEmpty && driver.properties(systemID) == nil
            try snapshot("manual-stop")

            energy.setKeepDisplaysOn(true)
            try energy.start(seconds: 1).get()
            let timedIDs = Array(energy.owned.values)
            try await Task.sleep(for: .seconds(1.2))
            energy.tick()
            checks["expiryReleasesBoth"] = energy.owned.isEmpty && timedIDs.allSatisfy { driver.properties($0) == nil }
            try snapshot("expired")

            // Deliberately do not poll EnergySession: validate the independent OS failsafe.
            let id = try driver.acquire(.system, timeout: 1).get()
            kernelID = id
            try await Task.sleep(for: .seconds(2.2))
            checks["kernelTimeoutReleasesWithoutAppPolling"] = driver.properties(id) == nil
            try driver.release(id).get()
            kernelID = nil
            checks["alreadyExpiredReleaseIsSafe"] = driver.properties(id) == nil

            if let anyInput = CGEventType(rawValue: UInt32.max) {
                let age = CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: anyInput)
                checks["idleScalarIsFiniteNonnegative"] = age.isFinite && age >= 0
            } else {
                checks["idleScalarIsFiniteNonnegative"] = false
            }
            try write([
                "kind": "native-energy-probe",
                "os": ProcessInfo.processInfo.operatingSystemVersionString,
                "timestamp": Date().ISO8601Format(),
                "checks": checks, "states": states,
                "allPassed": checks.values.allSatisfy { $0 },
                "boundary": "Assertion lifecycle and scalar availability, not actual sleep/display timing or fresh-install permission proof.",
            ], to: "energy.json")
        } catch {
            try? write(["allPassed": false, "error": String(describing: error), "states": states], to: "energy.json")
        }
    }
}
