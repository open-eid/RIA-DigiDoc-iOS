// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MobileIdLib",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "MobileIdLib",
            targets: ["MobileIdLib"]
        ),
        .library(name: "MobileIdLibMocks", targets: ["MobileIdLibMocks"])
    ],
    dependencies: [
        .package(url: "https://github.com/hmlongco/Factory", exact: .init(2, 5, 3)),
        .package(url: "https://github.com/Alamofire/Alamofire.git", exact: .init(5, 11, 2)),
        .package(path: "../CommonsLib"),
        .package(path: "../UtilsLib")
    ],
    targets: [
        .target(
            name: "MobileIdLib",
            dependencies: [
                "Alamofire",
                "CommonsLib",
                "UtilsLib",
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
            name: "MobileIdLibMocks",
            dependencies: ["MobileIdLib"],
            path: "Tests/Mocks/Generated"
        ),
        .testTarget(
            name: "MobileIdLibTests",
            dependencies: [
                "MobileIdLib",
                "MobileIdLibMocks",
                "CommonsLib",
                "UtilsLib",
                .product(name: "CommonsLibMocks", package: "commonslib"),
                .product(name: "FactoryTesting", package: "Factory")
            ]
        )
    ]
)
