// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FluxTalkBackend",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "FluxTalkBackend", targets: ["FluxTalkBackend"])
    ],
    dependencies: [
        // Vapor framework
        .package(url: "https://github.com/vapor/vapor.git", from: "4.99.0"),
        // SQLite database
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.6.0"),
    ],
    targets: [
        .executableTarget(
            name: "FluxTalkBackend",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
            ]
        ),
    ]
)
