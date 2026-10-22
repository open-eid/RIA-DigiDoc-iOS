// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import Testing
import CommonsLib
import FactoryKit
import UtilsLib
@testable import CryptoSwift

struct CryptoContainerTests {

    private let fileManager: FileManagerProtocol = Container.shared.fileManager()
    private let containerUtil: ContainerUtilProtocol = Container.shared.containerUtil()

    private func makeContainer() -> CryptoContainer {
        CryptoContainer(
            containerFile: URL(fileURLWithPath: "/tmp/container.cdoc2"),
            fileManager: fileManager,
            containerUtil: containerUtil
        )
    }

    private func containerTempDirectory() throws -> URL {
        try Directories.getCacheDirectory(
            subfolders: [CommonsLib.Constants.Folder.ContainerFolder, CommonsLib.Constants.Folder.Temp],
            fileManager: fileManager
        )
    }

    @Test
    func addDataFiles_keepsFileThatIsAlreadyInTheDestinationDirectory() async throws {
        let name = "already-cached-\(UUID().uuidString).txt"
        let alreadyCached = try containerTempDirectory().appending(path: name)
        try Data("payload".utf8).write(to: alreadyCached)
        defer { try? FileManager.default.removeItem(at: alreadyCached) }

        let container = makeContainer()
        try await container.addDataFiles([alreadyCached])

        let dataFiles = await container.getDataFiles()

        #expect(dataFiles.map(\.lastPathComponent) == [name])
        #expect(FileManager.default.fileExists(atPath: alreadyCached.path(percentEncoded: false)))
        #expect(try String(contentsOf: alreadyCached, encoding: .utf8) == "payload")
    }

    @Test
    func addDataFiles_reportsAFailureWhenTheFileAtTheDestinationIsMissing() async throws {
        let missing = try containerTempDirectory()
            .appending(path: "never-written-\(UUID().uuidString).txt")

        let container = makeContainer()

        await #expect(throws: CryptoError.self) {
            try await container.addDataFiles([missing])
        }

        let dataFiles = await container.getDataFiles()

        #expect(dataFiles.isEmpty)
    }

    @Test
    func addDataFiles_matchesTheDestinationThroughASymlinkedPath() async throws {
        let name = "symlinked-\(UUID().uuidString).txt"
        let destination = try containerTempDirectory().appending(path: name)
        try Data("payload".utf8).write(to: destination)
        defer { try? FileManager.default.removeItem(at: destination) }

        let viaSymlink = destination.resolvingSymlinksInPath()

        let container = makeContainer()
        try await container.addDataFiles([viaSymlink])

        #expect(FileManager.default.fileExists(atPath: destination.path(percentEncoded: false)))
        #expect(try String(contentsOf: destination, encoding: .utf8) == "payload")
    }
}
