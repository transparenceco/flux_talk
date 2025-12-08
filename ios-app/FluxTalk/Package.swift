// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "FluxTalk",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "FluxTalk",
            targets: ["FluxTalk"]
        ),
    ],
    dependencies: [
        // Exyte Chat library for chat UI
        .package(url: "https://github.com/exyte/Chat.git", from: "1.2.0"),
    ],
    targets: [
        .target(
            name: "FluxTalk",
            dependencies: [
                .product(name: "ExyteChat", package: "Chat"),
            ]
        ),
    ]
)
