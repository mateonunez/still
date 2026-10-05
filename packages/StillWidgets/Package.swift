// swift-tools-version: 6.0
import PackageDescription
let package = Package(name: "StillWidgets", platforms: [.macOS(.v14)], products: [.library(name: "StillWidgets", targets: ["StillWidgets"])], targets: [.target(name: "StillWidgets"), .testTarget(name: "StillWidgetsTests", dependencies: ["StillWidgets"])])
