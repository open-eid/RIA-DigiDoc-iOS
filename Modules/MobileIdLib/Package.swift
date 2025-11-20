// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MobileIdLib",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "MobileIdLib",
            targets: ["MobileIdLib"]
        ),
        .library(name: "MobileIdLibMocks", targets: ["MobileIdLibMocks"])
    ],
    dependencies: [
        .package(url: "https://github.com/hmlongco/Factory", exact: .init(2, 5, 3)),
        .package(url: "https://github.com/Alamofire/Alamofire.git", exact: .init(5, 10, 2)),
        .package(path: "../CommonsLib")
    ],
    targets: [
        .target(
            name: "MobileIdLib",
            dependencies: [
                "Alamofire",
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
            name: "MobileIdLibMocks",
            dependencies: ["MobileIdLib"],
            path: "Tests/Mocks/Generated"
        ),
        .testTarget(
            name: "MobileIdLibTests",
            dependencies: [
                "MobileIdLib",
                "CommonsLib",
                .product(name: "CommonsLibMocks", package: "commonslib"),
                .product(name: "FactoryTesting", package: "Factory")
            ]
        )
    ]
)
