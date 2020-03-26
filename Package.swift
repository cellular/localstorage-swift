// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "LocalStorage",
    platforms: [
        .iOS(.v11), .tvOS(.v11), .watchOS(.v5)
    ],
    products: [
        .library(name: "LocalStorage", type: .dynamic, targets: ["LocalStorage"])
    ],
    dependencies: [
        .package(url: "https://github.com/cellular/cellular-swift.git", from: "6.0.1")
    ],
    targets: [
        .target(name: "LocalStorage", dependencies: ["CELLULAR"]),
        .testTarget(name: "LocalStorageTests", dependencies: ["LocalStorage"])
    ]
)
