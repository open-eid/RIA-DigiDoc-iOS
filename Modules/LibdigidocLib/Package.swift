// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LibdigidocLib",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "LibdigidocLib",
            targets: ["LibdigidocLibSwift"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Swinject/Swinject.git", exact: .init(2, 9, 1)),
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
            dependencies: ["LibdigidocLibObjC", "Swinject", "CommonsLib", "ConfigLib", "UtilsLib"],
            path: "Sources/LibdigidocSwift"
        ),
        .testTarget(
            name: "LibdigidocLibTests",
            dependencies: ["LibdigidocLibSwift", "ConfigLib", "CommonsLib", "UtilsLib", "CommonsTestShared"]
        )
    ]
)
