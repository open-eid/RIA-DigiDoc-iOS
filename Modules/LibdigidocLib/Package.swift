// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "LibdigidocLib",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "LibdigidocLib",
            targets: ["LibdigidocLibSwift"]
        ),
        .library(name: "LibdigidocLibSwiftMocks", targets: ["LibdigidocLibSwiftMocks"])
    ],
    dependencies: [
        .package(url: "https://github.com/hmlongco/Factory", exact: .init(2, 5, 3)),
        .package(path: "../ConfigLib"),
        .package(path: "../CommonsLib"),
        .package(path: "../UtilsLib"),
        .package(path: "../Test/CommonsTestShared")
    ],
    targets: [
        .binaryTarget(
            name: "digidocpp",
            path: "./Sources/LibdigidocObjC/Libs/digidocpp.xcframework"
        ),
        .target(
            name: "LibdigidocLibObjC",
            dependencies: ["digidocpp"],
            path: "Sources/LibdigidocObjC",
            publicHeadersPath: "include",
            cxxSettings: [
                .unsafeFlags(["-std=gnu17", "-std=gnu++20"])
            ],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
        .target(
            name: "LibdigidocLibSwift",
            dependencies: [
                "LibdigidocLibObjC",
                "CommonsLib",
                "ConfigLib",
                "UtilsLib",
                .product(name: "FactoryKit", package: "Factory")
            ],
            path: "Sources/LibdigidocSwift",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("SendableByDefault"),
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances")
            ]
        ),
        .target(
            name: "LibdigidocLibSwiftMocks",
            dependencies: ["LibdigidocLibSwift"],
            path: "Tests/Mocks"
        ),
        .testTarget(
            name: "LibdigidocLibTests",
            dependencies: [
                "LibdigidocLibSwift",
                "LibdigidocLibSwiftMocks",
                "ConfigLib",
                "CommonsLib",
                "UtilsLib",
                "CommonsTestShared",
                .product(name: "UtilsLibMocks", package: "utilslib"),
                .product(name: "ConfigLibMocks", package: "configlib"),
                .product(name: "CommonsLibMocks", package: "commonslib"),
                .product(name: "FactoryTesting", package: "Factory")
            ]
        )
    ]
)
