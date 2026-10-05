// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Still",
    platforms: [.macOS(.v14)],
    dependencies: [.package(path: "../../packages/SessionKit"), .package(path: "../../packages/StillWidgets"), .package(path: "../../packages/StillPluginKit"), .package(path: "../../packages/StillNativePlugins")],
    targets: [.executableTarget(name: "Still", dependencies: ["SessionKit", "StillWidgets", "StillPluginKit", "StillNativePlugins"]), .executableTarget(name: "StillClaudeBridge", dependencies: ["StillWidgets"]), .executableTarget(name: "StillAgentBridge", dependencies: ["StillWidgets"]), .executableTarget(name: "StillSpotifyBridge"), .testTarget(name: "StillTests", dependencies: ["Still"])]
)
