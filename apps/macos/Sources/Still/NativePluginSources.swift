import AppKit
import Carbon
import EventKit
import IOKit.ps
import StillNativePlugins

@MainActor
final class CalendarPluginSource {
    let store = EKEventStore()
    var calendars: [EKCalendar] { EKEventStore.authorizationStatus(for: .event) == .fullAccess ? store.calendars(for: .event) : [] }
    func requestAccess() async -> Bool { (try? await store.requestFullAccessToEvents()) ?? false }
    func read(_ settings: NativePluginSettings) -> NativePluginCard {
        guard EKEventStore.authorizationStatus(for: .event) == .fullAccess else { return NativePluginCard(.nextUp, state: .permissionRequired, detail: "Allow calendar access in plugin settings.") }
        guard let calendar = calendars.first(where: { $0.calendarIdentifier == settings.calendarID }) else { return NativePluginCard(.nextUp, state: .setupRequired, detail: "Choose one calendar in plugin settings.") }
        let now = Date()
        let predicate = store.predicateForEvents(withStart: now, end: now.addingTimeInterval(86400), calendars: [calendar])
        let event = store.events(matching: predicate).filter { !$0.isAllDay && $0.endDate > now }.sorted { $0.startDate < $1.startDate }.first
        let fact = event.map { AgendaFact(title: settings.showTitles ? String(($0.title ?? "Next event").prefix(80)).replacingOccurrences(of: "\n", with: " ") : "Next event", startsAt: $0.startDate) }
        return NativePluginCard(.nextUp, payload: .agenda(fact), state: .ready, detail: "Selected calendar · \(settings.showTitles ? "titles visible" : "titles hidden")", observedAt: now, expiresAt: now.addingTimeInterval(120))
    }
}

enum SpotifyPluginSource {
    static func permission(ask: Bool) -> OSStatus {
        let target = NSAppleEventDescriptor(bundleIdentifier: "com.spotify.client")
        return AEDeterminePermissionToAutomateTarget(target.aeDesc, AEEventClass(kAECoreSuite), AEEventID(kAEGetData), ask)
    }
    static func read(showTitles: Bool) async -> NativePluginCard {
        guard let helper = Bundle.main.executableURL?.deletingLastPathComponent().appendingPathComponent("StillSpotifyBridge") else { return NativePluginCard(.spotify, state: .setupRequired, detail: "Spotify helper is missing. Rebuild the development app.") }
        switch await NativeReadCommand.fetch(executable: helper, arguments: [showTitles ? "--show-titles" : "--hide-titles"], timeoutSeconds: 7) {
        case .success(let data):
            guard let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return NativePluginCard(.spotify, state: .unavailable, detail: "Spotify returned an unsupported response.") }
            guard object["state"] as? String == "ready", let title = object["title"] as? String, let artist = object["artist"] as? String, let playing = object["playing"] as? Bool else { return NativePluginCard(.spotify, state: object["state"] as? String == "permissionRequired" ? .permissionRequired : .unavailable, detail: "Open Spotify and check Automation access in plugin settings.") }
            let now = Date()
            return NativePluginCard(.spotify, payload: .playback(PlaybackFact(title: title, artist: artist, playing: playing)), state: .ready, detail: "Local Spotify · read only", observedAt: now, expiresAt: now.addingTimeInterval(30))
        case .failure: return NativePluginCard(.spotify, state: .unavailable, detail: "Spotify did not respond. Check the local app and Automation access.")
        }
    }
}

@MainActor
final class MacPulseSource {
    private var lastTicks: [UInt32]?
    func read(_ settings: NativePluginSettings) -> NativePluginCard {
        var info = host_cpu_load_info(), count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info>.size / MemoryLayout<integer_t>.size)
        let status = withUnsafeMutablePointer(to: &info) { pointer in pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count) } }
        var metrics: [MetricFact] = []
        if status == KERN_SUCCESS {
            let ticks = [info.cpu_ticks.0, info.cpu_ticks.1, info.cpu_ticks.2, info.cpu_ticks.3]
            if let previous = lastTicks {
                let delta = zip(ticks, previous).map { Double($0 &- $1) }, total = delta.reduce(0, +)
                if total > 0 { metrics.append(MetricFact("CPU", "\(Int((1 - delta[2] / total) * 100))%")) }
            }
            lastTicks = ticks
        }
        if !metrics.contains(where: { $0.label == "CPU" }) { metrics.append(MetricFact("CPU", "Sampling…")) }
        var pressure: Int32 = 0, size = MemoryLayout<Int32>.size
        let result = sysctlbyname("kern.memorystatus_vm_pressure_level", &pressure, &size, nil, 0)
        metrics.append(MetricFact("Memory pressure", result == 0 ? pressure == 1 ? "Normal" : pressure == 2 ? "Elevated" : pressure == 4 ? "Critical" : "Unknown" : "Unavailable"))
        if let info = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(), let sources = IOPSCopyPowerSourcesList(info)?.takeRetainedValue() as? [CFTypeRef] {
            if let source = sources.first, let description = IOPSGetPowerSourceDescription(info, source)?.takeUnretainedValue() as? [String: Any],
               let capacity = description[kIOPSCurrentCapacityKey] as? Int, let maximum = description[kIOPSMaxCapacityKey] as? Int, maximum > 0 {
                metrics.append(MetricFact("Battery", "\(min(100, max(0, capacity * 100 / maximum)))% · \((description[kIOPSPowerSourceStateKey] as? String) == kIOPSACPowerValue ? "AC" : "Battery")"))
            } else { metrics.append(MetricFact("Power", "External power")) }
        }
        let now = Date()
        metrics = metrics.filter { $0.label == "CPU" ? settings.showCPU : $0.label == "Memory pressure" ? settings.showMemory : settings.showBattery }
        return NativePluginCard(.macPulse, payload: .metrics(metrics), state: .ready, detail: "Native system metrics", observedAt: now, expiresAt: now.addingTimeInterval(10))
    }
}

enum WeatherPluginSource {
    static func read(_ settings: NativePluginSettings) async -> NativePluginCard {
        guard !settings.city.isEmpty else { return NativePluginCard(.weather, state: .setupRequired, detail: "Choose a city and coordinates in plugin settings.") }
        var url = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
        url.queryItems = [URLQueryItem(name: "latitude", value: String(settings.latitude)), URLQueryItem(name: "longitude", value: String(settings.longitude)), URLQueryItem(name: "current", value: "temperature_2m,weather_code"), URLQueryItem(name: "hourly", value: "precipitation_probability"), URLQueryItem(name: "forecast_days", value: "2"), URLQueryItem(name: "timeformat", value: "unixtime")]
        do {
            var request = URLRequest(url: url.url!); request.timeoutInterval = 12
            let (bytes, response) = try await URLSession.shared.bytes(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { return NativePluginCard(.weather, state: .unavailable, detail: "Weather service is unavailable. Try again later.") }
            var data = Data()
            for try await byte in bytes { guard data.count < 1048576 else { return NativePluginCard(.weather, state: .unavailable, detail: "Weather response exceeded its limit.") }; data.append(byte) }
            let now = Date()
            guard let (fact, observed) = SourceProjection.weather(data, city: settings.city, now: now) else { return NativePluginCard(.weather, state: .unavailable, detail: "Weather data is missing or out of date.") }
            return NativePluginCard(.weather, payload: .weather(fact), state: .ready, detail: "Open-Meteo · CC BY 4.0 · local evaluation", observedAt: observed, expiresAt: now.addingTimeInterval(1800))
        } catch { return NativePluginCard(.weather, state: .unavailable, detail: Task.isCancelled ? "Source paused" : "Weather could not connect. Check your network.") }
    }
}
