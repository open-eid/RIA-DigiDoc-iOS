// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ConfigLib",
    platforms: [.iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ConfigLib",
            targets: ["ConfigLib"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Swinject/Swinject.git", exact: .init(2, 9, 1)),
        .package(url: "https://github.com/Alamofire/Alamofire.git", exact: .init(5, 10, 2)),
        .package(url: "https://github.com/TakeScoop/SwiftyRSA", exact: .init(1, 8, 0)),
        .package(url: "https://github.com/Brightify/Cuckoo.git", exact: .init(2, 0, 10)),
        .package(path: "../CommonsLib"),
        .package(path: "../UtilsLib"),
        .package(path: "../CommonsLib/CommonsTestShared")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ConfigLib",
            dependencies: ["Swinject", "Alamofire", "CommonsLib", "SwiftyRSA", "UtilsLib"],
            resources: [
                .copy("Resources/config"),
                .copy("Resources/tslFiles")
            ]
        ),
        .testTarget(
            name: "ConfigLibTests",
            dependencies: ["ConfigLib", "Swinject", "Cuckoo", "CommonsLib", "UtilsLib", "CommonsTestShared"],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        )
    ]
)
