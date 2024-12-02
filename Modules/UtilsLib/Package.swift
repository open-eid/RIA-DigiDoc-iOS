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
        .package(url: "https://github.com/Swinject/Swinject.git", exact: .init(2, 9, 1)),
        .package(url: "https://github.com/weichsel/ZIPFoundation", exact: .init(0, 9, 19)),
        .package(url: "https://github.com/Brightify/Cuckoo.git", exact: .init(2, 0, 10)),
        .package(path: "../CommonsLib"),
        .package(path: "../CommonsLib/CommonsTestShared")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "UtilsLib",
            dependencies: ["Swinject", "ZIPFoundation", "CommonsLib"]
        ),
        .testTarget(
            name: "UtilsLibTests",
            dependencies: ["UtilsLib", "Swinject", "Cuckoo", "CommonsLib", "CommonsTestShared"],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        )
    ]
)
