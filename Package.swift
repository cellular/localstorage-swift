// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "LocalStorage",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "LocalStorage", targets: ["MyLibrary"]),
    ],
    dependencies: [
        .package(url: "https://github.com/cellular/cellular-swift.git", from: "6.0")
    ],
    targets: [
        .target(name: "MyLibrary", dependencies: ["Utility"]),
        .testTarget(name: "LocalStorageTests", dependencies: ["LocalStorage"]),
    ]
)