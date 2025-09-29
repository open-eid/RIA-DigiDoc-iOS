// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "IdCardLib",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "nfclib",
            targets: ["nfclib"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/leif-ibsen/BigInt.git", exact: .init(1, 21, 0)),
        .package(url: "https://github.com/leif-ibsen/Digest.git", exact: .init(1, 13, 0)),
        .package(url: "https://github.com/apple/swift-asn1.git", exact: .init(1, 4, 0)),
        .package(url: "https://github.com/apple/swift-certificates.git", exact: .init(1, 7, 0)),
        .package(url: "https://github.com/leif-ibsen/SwiftECC.git", exact: .init(5, 5, 0))
    ],
    targets: [
        .target(
            name: "nfclib",
            dependencies: [
                .product(name: "SwiftASN1", package: "swift-asn1"),
                .product(name: "X509", package: "swift-certificates"),
                "BigInt",
                "Digest",
                "SwiftECC"
            ],
            path: "Sources/IdCardLib/nfclib",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("SendableByDefault"),
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances")
            ]
        )
    ]
)
