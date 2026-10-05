// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "StillPluginKit",
    platforms: [.macOS(.v14)],
    products: [.library(name: "StillPluginKit", targets: ["StillPluginKit"]), .executable(name: "still-plugin", targets: ["StillPluginCLI"])],
    targets: [.target(name: "StillPluginKit"), .executableTarget(name: "StillPluginCLI", dependencies: ["StillPluginKit"]), .testTarget(name: "StillPluginKitTests", dependencies: ["StillPluginKit"])]
)
