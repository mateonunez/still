// swift-tools-version: 6.0
import PackageDescription

let package = Package(name: "StillNativePlugins", platforms: [.macOS(.v14)],
    products: [.library(name: "StillNativePlugins", targets: ["StillNativePlugins"])],
    targets: [.target(name: "StillNativePlugins"), .testTarget(name: "StillNativePluginsTests", dependencies: ["StillNativePlugins"])])
