// swift-tools-version: 6.0
import PackageDescription

let packageRoot = #filePath
    .split(separator: "/", omittingEmptySubsequences: false)
    .dropLast() // drop "Package.swift"
    .joined(separator: "/")

let package = Package(
    name: "CryptoLib",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "CryptoLib",
            targets: ["CryptoSwift"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/filom/ASN1Decoder", exact: .init(1, 10, 0)),
        .package(url: "https://github.com/hmlongco/Factory", exact: .init(2, 5, 3)),
        .package(path: "../ConfigLib"),
        .package(path: "../CommonsLib"),
        .package(path: "../UtilsLib")
    ],
    targets: [
        .binaryTarget(
            name: "cdoc",
            path: "./Sources/CryptoObjC/Libs/cdoc.xcframework"
        ),
        .systemLibrary(
            name: "LDAP",
            path: "./Sources/CryptoObjC/Libs/openldap/include",
        ),
        .target(
            name: "CryptoObjC",
            dependencies: [
                "cdoc",
                "CryptoObjCWrapper"
            ],
            path: "Sources/CryptoObjC",
            publicHeadersPath: "include",
            cxxSettings: [
                .unsafeFlags(["-std=c++17"])
            ]
        ),
        .target(
            name: "CryptoSwift",
            dependencies: [
                "CryptoObjC",
                "CommonsLib",
                "ConfigLib",
                "UtilsLib",
                "ASN1Decoder",
                .product(name: "FactoryKit", package: "Factory")
            ],
            path: "Sources/CryptoSwift",
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]
        ),
        .target(
            name: "CryptoObjCWrapper",
            dependencies: [
                "LDAP",
                "ASN1Decoder",
                .product(name: "FactoryKit", package: "Factory")
            ],
            path: "Sources/CryptoObjCWrapper",
            linkerSettings: [
                .unsafeFlags([
                      "-L", "\(packageRoot)/Sources/CryptoObjC/Libs/openldap/lib",
                      "-L", "\(packageRoot)/Sources/CryptoObjC/Libs/openssl"
                 ]),
            ]
        ),
    ]
)
