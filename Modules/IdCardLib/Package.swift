// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "IdCardLib",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "IdCardLib",
            targets: ["nfclib"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/leif-ibsen/BigInt.git", exact: .init(1, 23, 0))
    ],
    targets: [
        .binaryTarget(
            name: "nfclib",
            path: "Frameworks/nfclib.xcframework"
        )
    ]
)
