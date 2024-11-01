// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Libdigidoclib",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "Libdigidoclib",
            targets: ["LibdigidoclibSwift"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Swinject/Swinject.git", exact: .init(2, 9, 1))
    ],
    targets: [
        .binaryTarget(
            name: "digidocpp",
            path: "./Sources/LibdigidocObjC/Libs/digidocpp.xcframework"
        ),
        .target(
            name: "LibdigidoclibObjC",
            dependencies: ["digidocpp"],
            path: "Sources/LibdigidocObjC",
            publicHeadersPath: "include",
            cxxSettings: [
                .unsafeFlags(["-std=c++17"])
            ],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
        .target(
            name: "LibdigidoclibSwift",
            dependencies: ["LibdigidoclibObjC", "Swinject"],
            path: "Sources/LibdigidocSwift"
        ),
        .testTarget(
            name: "LibdigidoclibTests",
            dependencies: ["LibdigidoclibSwift"]
        )
    ]
)
