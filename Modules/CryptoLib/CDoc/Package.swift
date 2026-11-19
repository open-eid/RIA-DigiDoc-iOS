// swift-tools-version: 6.3;(experimentalCGen)
// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import PackageDescription

let package = Package(
    name: "CDoc",
    platforms: [.iOS(.v18)],
    products: [.library(name: "cdoc", targets: ["cdoc"])],
    targets: [
        .binaryTarget(
            name: "OpenSSL",
            path: "OpenSSL.xcframework"
        ),
        .target(
            name: "cdoc",
            dependencies: ["OpenSSL"],
            path: ".",
            exclude: [
                "libcdoc/cdoc/CDocException.java",
                "libcdoc/cdoc/CMakeLists.txt",
                "libcdoc/cdoc/IStreamSource.java",
                "libcdoc/cdoc/KeyShares.cpp",
                "libcdoc/cdoc/WinBackend.cpp",
                "libcdoc/cdoc/cdoc-tool.cpp",
                "libcdoc/cdoc/cdoc-tool.manifest",
                "libcdoc/cdoc/libcdoc.rc",
                "libcdoc/cdoc/schema"
            ],
            sources: ["libcdoc/cdoc"],
            cxxSettings: [
                .define("VERSION_STR", to: "\"0.5.1.0\""),
                .headerSearchPath("libcdoc"),
                .headerSearchPath("libcdoc/cdoc"),
                .unsafeFlags(["-std=c++23", "-iwithsysroot", "/usr/include/libxml2", "-Wno-shorten-64-to-32"])
            ],
            linkerSettings: [
                .linkedLibrary("xml2"),
                .linkedLibrary("z")
            ],
            plugins: [.plugin(name: "GenerateCDocFlatBuffers")]
        ),
        .plugin(
            name: "GenerateCDocFlatBuffers",
            capability: .buildTool()
        )
    ]
)
