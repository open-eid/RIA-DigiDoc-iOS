// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ConfigLib",
    platforms: [.iOS(.v18)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ConfigLib",
            targets: ["ConfigLib"]
        ),
        .library(name: "ConfigLibMocks", targets: ["ConfigLibMocks"])
    ],
    dependencies: [
        .package(url: "https://github.com/hmlongco/Factory", exact: .init(2, 5, 3)),
        .package(url: "https://github.com/Alamofire/Alamofire.git", exact: .init(5, 11, 2)),
        .package(url: "https://github.com/TakeScoop/SwiftyRSA", exact: .init(1, 8, 0)),
        .package(path: "../CommonsLib"),
        .package(path: "../UtilsLib"),
        .package(path: "../Test/CommonsTestShared")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ConfigLib",
            dependencies: [
                "Alamofire",
                "CommonsLib",
                "SwiftyRSA",
                "UtilsLib",
                .product(name: "FactoryKit", package: "Factory")
            ],
            resources: [
                .copy("Resources/config"),
                .copy("Resources/tslFiles")
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("SendableByDefault"),
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances")
            ]
        ),
        .target(
            name: "ConfigLibMocks",
            dependencies: [
                "ConfigLib",
                "CommonsTestShared"
            ],
            path: "Tests/Mocks"
        ),
        .testTarget(
            name: "ConfigLibTests",
            dependencies: [
                "ConfigLib",
                "ConfigLibMocks",
                "CommonsLib",
                "UtilsLib",
                "CommonsTestShared",
                .product(name: "FactoryTesting", package: "Factory"),
                .product(name: "CommonsLibMocks", package: "commonslib")
            ]
        )
    ]
)
