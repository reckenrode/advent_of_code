// swift-tools-version: 5.7
// SPDX-License-Identifier: GPL-3.0-only

import PackageDescription

let package = Package(
    name: "advent",
    platforms: [.macOS(.v13)],

    products: [
        .executable(name: "advent", targets: ["advent"]),
        .library(name: "advent_common", targets: ["AdventCommon"])
    ],

    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
    ],

    targets: [
        .executableTarget(
            name: "advent",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "AdventCommon"
            ]
        ),
        .target(
            name: "AdventCommon",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .testTarget(
            name: "AdventCommonTests",
            dependencies: ["AdventCommon"]
        ),
        .testTarget(
            name: "adventTests",
            dependencies: ["advent"]
        ),
    ]
)
