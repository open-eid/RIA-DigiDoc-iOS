// swift-tools-version: 6.3
import PackageDescription

let packageRoot = #filePath
    .split(separator: "/", omittingEmptySubsequences: false)
    .dropLast() // drop "Package.swift"
    .joined(separator: "/")

let package = Package(
    name: "CryptoLib",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "CryptoLib",
            targets: ["CryptoSwift"]
        ),
        .library(name: "CryptoLibMocks", targets: ["CryptoLibMocks"])
    ],
    dependencies: [
        .package(url: "https://github.com/filom/ASN1Decoder", exact: .init(1, 10, 0)),
        .package(url: "https://github.com/leif-ibsen/BigInt.git", exact: .init(1, 24, 0)),
        .package(url: "https://github.com/hmlongco/Factory", exact: .init(3, 3, 2)),
        .package(path: "../ConfigLib"),
        .package(path: "../CommonsLib"),
        .package(path: "../IdCardLib"),
        .package(path: "../UtilsLib"),
        .package(path: "../Test/CommonsTestShared")
    ],
    targets: [
        .binaryTarget(
            name: "cdoc",
            path: "./Sources/CryptoObjC/Libs/cdoc.xcframework"
        ),
        .binaryTarget(
            name: "LDAP",
            path: "./Sources/CryptoObjC/Libs/LDAP.xcframework"
        ),
        .target(
            name: "CryptoObjCWrapper",
            dependencies: [
                "LDAP",
                "ASN1Decoder",
                "CommonsLib",
                "ConfigLib",
                "IdCardLib",
                "UtilsLib",
                .product(name: "FactoryKit", package: "Factory")
            ],
            path: "Sources/CryptoObjCWrapper",
            cSettings: [
                .unsafeFlags(["-fmodules"])
            ],
            cxxSettings: [
                .unsafeFlags(["-std=c++20", "-fcxx-modules"])
            ]
        ),
        .target(
            name: "CryptoObjC",
            dependencies: [
                "cdoc",
                "CryptoObjCWrapper"

            ],
            path: "Sources/CryptoObjC",
            publicHeadersPath: "include",
            cSettings: [
                .unsafeFlags(["-fmodules"])
            ],
            cxxSettings: [
                .unsafeFlags(["-std=c++20", "-fcxx-modules"])
            ]
        ),
        .target(
            name: "CryptoSwift",
            dependencies: [
                "CryptoObjC",
                "CryptoObjCWrapper",
                "CommonsLib",
                "ConfigLib",
                "UtilsLib",
                "ASN1Decoder",
                "BigInt",
                .product(name: "FactoryKit", package: "Factory")
            ],
            path: "Sources/CryptoSwift",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("SendableByDefault"),
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances")
            ]
        ),
        .target(
            name: "CryptoLibMocks",
            dependencies: ["CryptoSwift"],
            path: "Tests/Mocks"
        ),
        .testTarget(
            name: "CryptoSwiftTests",
            dependencies: [
                "ConfigLib",
                "CryptoSwift",
                "CryptoObjCWrapper",
                "CryptoLibMocks",
                "CommonsLib",
                "UtilsLib",
                "CommonsTestShared",
                .product(name: "CommonsLibMocks", package: "commonslib"),
                .product(name: "FactoryTesting", package: "Factory")
            ]
        )
    ]
)
