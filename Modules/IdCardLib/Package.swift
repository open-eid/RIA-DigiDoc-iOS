// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "IdCardLib",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "IdCardLib",
            targets: ["IdCardLib"]
        ),
        .library(name: "IdCardLibMocks", targets: ["IdCardLibMocks"])
    ],
    dependencies: [
        .package(url: "https://github.com/hmlongco/Factory", exact: .init(2, 5, 3)),
        .package(url: "https://github.com/leif-ibsen/BigInt.git", exact: .init(1, 21, 0)),
        .package(url: "https://github.com/leif-ibsen/Digest.git", exact: .init(1, 13, 0)),
        .package(url: "https://github.com/filom/ASN1Decoder", exact: .init(1, 10, 0)),
        .package(url: "https://github.com/leif-ibsen/SwiftECC.git", exact: .init(5, 5, 0)),
        .package(path: "../UtilsLib"),
        .package(path: "../CommonsLib")
    ],
    targets: [
        .target(
            name: "iR301",
            dependencies: ["iR301Binary"],
            path: "Sources/bR301",
            publicHeadersPath: "include"
        ),
        .binaryTarget(
            name: "iR301Binary",
            path: "Sources/bR301/bR301.xcframework"
        ),
        .target(
            name: "IdCardLib",
            dependencies: [
                "ASN1Decoder",
                "BigInt",
                "Digest",
                "SwiftECC",
                "iR301",
                "UtilsLib",
                "CommonsLib",
                .product(name: "FactoryKit", package: "Factory")
            ],
            path: "Sources/IdCardLib",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("SendableByDefault"),
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances")
            ],
            linkerSettings: [
                .linkedFramework("CoreBluetooth", .when(platforms: [.iOS])),
                .linkedFramework("ExternalAccessory", .when(platforms: [.iOS])),
                .unsafeFlags(["-ObjC"], .when(platforms: [.iOS])),
                .linkedLibrary("c++", .when(platforms: [.iOS]))
            ]
        ),
        .target(
            name: "IdCardLibMocks",
            dependencies: ["IdCardLib"],
            path: "Tests/Mocks/Generated"
        ),
        .testTarget(
            name: "IdCardLibTests",
            dependencies: [
                "IdCardLib",
                "IdCardLibMocks",
                .product(name: "FactoryTesting", package: "Factory")
            ]
        )
    ]
)
