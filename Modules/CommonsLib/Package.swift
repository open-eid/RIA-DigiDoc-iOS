// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CommonsLib",
    platforms: [.iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CommonsLib",
            targets: ["CommonsLib"]
        ),
        .library(name: "CommonsLibMocks", targets: ["CommonsLibMocks"])
    ],
    dependencies: [
        .package(url: "https://github.com/hmlongco/Factory", exact: .init(2, 5, 3))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CommonsLib",
            dependencies: [
                .product(name: "FactoryKit", package: "Factory")
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("SendableByDefault"),
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances")
            ]
        ),
        .target(
            name: "CommonsLibMocks",
            dependencies: ["CommonsLib"],
            path: "Tests/Mocks/Generated"
        )
    ]
)
