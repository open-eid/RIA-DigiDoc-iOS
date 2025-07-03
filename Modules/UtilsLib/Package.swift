// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UtilsLib",
    platforms: [.iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "UtilsLib",
            targets: ["UtilsLib"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/hmlongco/Factory", exact: .init(2, 5, 3)),
        .package(url: "https://github.com/weichsel/ZIPFoundation", exact: .init(0, 9, 19)),
        .package(path: "../CommonsLib"),
        .package(path: "../CommonsLib/CommonsTestShared")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "UtilsLib",
            dependencies: [
                "ZIPFoundation",
                "CommonsLib",
                .product(name: "FactoryKit", package: "Factory")
            ]
        ),
        .testTarget(
            name: "UtilsLibTests",
            dependencies: [
                "CommonsLib",
                "CommonsTestShared",
                .product(name: "UtilsLibMocks", package: "commonstestshared"),
                .product(name: "CommonsLibMocks", package: "commonstestshared"),
                .product(name: "ConfigLibMocks", package: "commonstestshared"),
                .product(name: "FactoryTesting", package: "Factory")
            ]
        )
    ]
)
