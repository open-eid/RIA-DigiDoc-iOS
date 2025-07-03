// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CommonsTestShared",
    platforms: [.iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "CommonsTestShared", targets: ["CommonsTestShared"]),
        .library(name: "ConfigLibMocks", targets: ["ConfigLibMocks"]),
        .library(name: "CommonsLibMocks", targets: ["CommonsLibMocks"]),
        .library(name: "UtilsLibMocks", targets: ["UtilsLibMocks"])
    ],
    dependencies: [
        .package(url: "https://github.com/weichsel/ZIPFoundation", exact: .init(0, 9, 19)),
        .package(path: "../CommonsLib"),
        .package(path: "../../ConfigLib"),
        .package(path: "../../UtilsLib")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CommonsTestShared",
            dependencies: ["ZIPFoundation", "CommonsLib"],
            exclude: ["Mocks"],
            resources: [
                .process("Resources/example.asice")
            ]
        ),
        .target(
            name: "ConfigLibMocks",
            dependencies: ["ConfigLib"],
            path: "Sources/CommonsTestShared/Mocks/ConfigLibMocks/Generated"
        ),
        .target(
            name: "CommonsLibMocks",
            dependencies: ["CommonsLib"],
            path: "Sources/CommonsTestShared/Mocks/CommonsLibMocks/Generated"
        ),
        .target(
            name: "UtilsLibMocks",
            dependencies: ["UtilsLib"],
            path: "Sources/CommonsTestShared/Mocks/UtilsLibMocks/Generated"
        )
    ]
)
