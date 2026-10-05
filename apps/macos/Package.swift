// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Still",
    platforms: [.macOS(.v14)],
    dependencies: [.package(path: "../../packages/SessionKit"), .package(path: "../../packages/StillWidgets")],
    targets: [.executableTarget(name: "Still", dependencies: ["SessionKit", "StillWidgets"]), .executableTarget(name: "StillClaudeBridge", dependencies: ["StillWidgets"])]
)
