// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SmartIdLib",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "SmartIdLib",
            targets: ["SmartIdLib"]
        ),
        .library(name: "SmartIdLibMocks", targets: ["SmartIdLibMocks"])
    ],
    dependencies: [
        .package(url: "https://github.com/hmlongco/Factory", exact: .init(3, 3, 2)),
        .package(url: "https://github.com/Alamofire/Alamofire.git", exact: .init(5, 12, 0)),
        .package(path: "../UtilsLib"),
        .package(path: "../CommonsLib")
    ],
    targets: [
        .target(
            name: "SmartIdLib",
            dependencies: [
                "Alamofire",
                "UtilsLib",
                "CommonsLib",
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
            name: "SmartIdLibMocks",
            dependencies: ["SmartIdLib"],
            path: "Tests/Mocks/Generated"
        ),
        .testTarget(
            name: "SmartIdLibTests",
            dependencies: [
                "SmartIdLib",
                "SmartIdLibMocks",
                "UtilsLib",
                "CommonsLib",
                .product(name: "UtilsLibMocks", package: "utilslib"),
                .product(name: "CommonsLibMocks", package: "commonslib"),
                .product(name: "FactoryTesting", package: "Factory")
            ]
        )
    ]
)
