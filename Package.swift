// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "scrub",
    platforms: [.macOS(.v14)],
    products: [
        .executable(
            name: "scrub",
            targets: ["Scrub"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
    ],
    targets: [
        .target(
            name: "ScrubCore",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Sources/core"
        ),
        .executableTarget(
            name: "Scrub",
            dependencies: [
                "ScrubCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Sources/cli"
        ),
    ]
)
