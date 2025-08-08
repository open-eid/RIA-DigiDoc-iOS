// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LibdigidocLib",
    platforms: [.iOS(.v15)],
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
        .package(path: "../CommonsLib/CommonsTestShared")
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
                .unsafeFlags(["-std=c++17"])
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
            path: "Sources/LibdigidocSwift"
        ),
        .target(
            name: "LibdigidocLibSwiftMocks",
            dependencies: ["LibdigidocLibSwift"],
            path: "Tests/Mocks/Generated"
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
                .product(name: "CommonsLibMocks", package: "commonslib"),
                .product(name: "FactoryTesting", package: "Factory")
            ]
        )
    ]
)
