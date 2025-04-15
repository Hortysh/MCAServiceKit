// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MCAServiceKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "APIService",
            targets: ["APIService"]),
    ],
    targets: [
        .target(
            name: "APIService"),
        .testTarget(
            name: "APIServiceTests",
            dependencies: ["APIService"]
        )
    ]
)
