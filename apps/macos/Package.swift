// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Still",
    platforms: [.macOS(.v14)],
    dependencies: [.package(path: "../../packages/SessionKit"), .package(path: "../../packages/StillWidgets"), .package(path: "../../packages/StillPluginKit")],
    targets: [.executableTarget(name: "Still", dependencies: ["SessionKit", "StillWidgets", "StillPluginKit"]), .executableTarget(name: "StillClaudeBridge", dependencies: ["StillWidgets"]), .executableTarget(name: "StillAgentBridge", dependencies: ["StillWidgets"])]
)
