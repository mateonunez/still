// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SessionKit",
    platforms: [.macOS(.v14)],
    products: [.library(name: "SessionKit", targets: ["SessionKit"])],
    targets: [
        .target(name: "SessionKit"),
        .testTarget(name: "SessionKitTests", dependencies: ["SessionKit"]),
    ]
)
