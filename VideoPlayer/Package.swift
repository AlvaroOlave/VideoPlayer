// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VideoPlayer",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "VideoPlayer",
            targets: ["VideoPlayer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/AlvaroOlave/LoadingDots", .upToNextMajor(from: "0.0.1")),
        .package(url: "https://github.com/AlvaroOlave/AutoLayoutDSL", .upToNextMajor(from: "0.1.0")),
    ],
    targets: [
        .target(
            name: "VideoPlayer",
            dependencies: ["LoadingDots",
                           .product(name: "AutolayoutDSL", package: "AutoLayoutDSL")]),
    ]
)
