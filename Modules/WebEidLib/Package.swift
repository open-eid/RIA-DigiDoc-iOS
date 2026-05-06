// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WebEidLib",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "WebEidLib",
            targets: ["WebEidLib"]
        ),
        .library(name: "WebEidLibMocks", targets: ["WebEidLibMocks"])
    ],
    dependencies: [
        .package(url: "https://github.com/filom/ASN1Decoder", exact: .init(1, 10, 0)),
        .package(url: "https://github.com/hmlongco/Factory", exact: .init(2, 5, 3)),
        .package(url: "https://github.com/Alamofire/Alamofire.git", exact: .init(5, 11, 2)),
        .package(path: "../UtilsLib"),
        .package(path: "../CommonsLib"),
        .package(path: "../Test/CommonsTestShared")
    ],
    targets: [
        .target(
            name: "WebEidLib",
            dependencies: [
                "Alamofire",
                "ASN1Decoder",
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
            name: "WebEidLibMocks",
            dependencies: ["WebEidLib"],
            path: "Tests/Mocks/Generated"
        ),
        .testTarget(
            name: "WebEidLibTests",
            dependencies: [
                "WebEidLib",
                "WebEidLibMocks",
                "UtilsLib",
                "CommonsLib",
                "CommonsTestShared",
                .product(name: "UtilsLibMocks", package: "utilslib"),
                .product(name: "CommonsLibMocks", package: "commonslib"),
                .product(name: "FactoryTesting", package: "Factory")
            ]
        )
    ]
)
