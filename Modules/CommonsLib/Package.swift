// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CommonsLib",
    platforms: [.iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CommonsLib",
            targets: ["CommonsLib"])
    ],
    dependencies: [
        .package(url: "https://github.com/Brightify/Cuckoo.git", exact: .init(2, 0, 10)),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CommonsLib"),
        .testTarget(
            name: "CommonsLibTests",
            dependencies: ["CommonsLib", "Cuckoo"],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        )
    ]
)
