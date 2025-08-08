// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CommonsTestShared",
    platforms: [.iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "CommonsTestShared", targets: ["CommonsTestShared"])
    ],
    dependencies: [
        .package(url: "https://github.com/weichsel/ZIPFoundation", exact: .init(0, 9, 19)),
        .package(path: "../CommonsLib")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CommonsTestShared",
            dependencies: ["ZIPFoundation", "CommonsLib"],
            resources: [
                .process("Resources/example.asice")
            ]
        )
    ]
)
