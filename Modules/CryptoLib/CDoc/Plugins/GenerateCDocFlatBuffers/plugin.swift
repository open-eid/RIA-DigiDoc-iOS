// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import PackagePlugin

@main
struct GenerateCDocFlatBuffers: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        let fileManager = FileManager.default
        let environment = ProcessInfo.processInfo.environment
        let pathPrefixes = environment["PATH", default: ""].split(separator: ":")
            .map { URL(fileURLWithPath: String($0), isDirectory: true) }
            .filter { fileManager.isExecutableFile(atPath: $0.appendingPathComponent("brew").path) }
            .map { $0.deletingLastPathComponent().path }
        #if arch(arm64)
        let defaultPrefixes = ["/opt/homebrew", "/usr/local"]
        #else
        let defaultPrefixes = ["/usr/local", "/opt/homebrew"]
        #endif
        let prefixes = [environment["HOMEBREW_PREFIX"]].compactMap { $0 } + pathPrefixes + defaultPrefixes
        guard let flatBuffers = prefixes
            .map({ URL(fileURLWithPath: $0).appendingPathComponent("opt/flatbuffers").resolvingSymlinksInPath() })
            .first(where: {
                fileManager.isExecutableFile(atPath: $0.appendingPathComponent("bin/flatc").path)
                    && fileManager.fileExists(
                        atPath: $0.appendingPathComponent("include/flatbuffers/flatbuffers.h").path
                    )
            }) else {
            throw FlatBuffersUnavailable()
        }

        let flatc = flatBuffers.appendingPathComponent("bin/flatc")
        let headers = flatBuffers.appendingPathComponent("include/flatbuffers")
        let cdoc = context.package.directoryURL.appendingPathComponent("libcdoc/cdoc")
        let output = context.pluginWorkDirectoryURL.appendingPathComponent("include")
        let outputHeaders = output.appendingPathComponent("flatbuffers")
        let headerPaths = try fileManager.subpathsOfDirectory(atPath: headers.path)
            .filter { $0.hasSuffix(".h") }
            .sorted()
        let schemas = ["recipients", "header"]
        let schemaFiles = schemas.map { cdoc.appendingPathComponent("schema/\($0).fbs") }

        return [
            .buildCommand(
                displayName: "Copy FlatBuffers C++ headers",
                executable: URL(fileURLWithPath: "/bin/cp"),
                arguments: ["-R", headers.path + "/.", outputHeaders.path],
                inputFiles: headerPaths.map { headers.appendingPathComponent($0) },
                outputFiles: headerPaths.map { outputHeaders.appendingPathComponent($0) }
            ),
            .buildCommand(
                displayName: "Generate CDoc FlatBuffers headers",
                executable: flatc,
                arguments: ["--cpp", "--scoped-enums", "-o", output.path, "-I", cdoc.path]
                    + schemaFiles.map(\.path),
                inputFiles: [flatc] + schemaFiles,
                outputFiles: schemas.map { output.appendingPathComponent("\($0)_generated.h") }
            )
        ]
    }
}

private struct FlatBuffersUnavailable: Error, CustomStringConvertible {
    var description: String { "CDoc requires FlatBuffers. Run: brew install flatbuffers" }
}
