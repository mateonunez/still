// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Still",
    platforms: [.macOS(.v14)],
    dependencies: [.package(path: "../../packages/SessionKit")],
    targets: [.executableTarget(name: "Still", dependencies: ["SessionKit"])]
)
