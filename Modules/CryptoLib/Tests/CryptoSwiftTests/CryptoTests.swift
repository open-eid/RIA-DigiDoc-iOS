/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

import Foundation
import Testing
import CommonsLib
import FactoryKit
import UtilsLib
import CryptoObjCWrapper
@testable import CryptoSwift

struct CryptoContainerDataFileTests {

    private let fileManager: FileManagerProtocol = Container.shared.fileManager()
    private let containerUtil: ContainerUtilProtocol = Container.shared.containerUtil()

    private func makeContainer(dataFiles: [URL] = []) -> CryptoContainer {
        CryptoContainer(
            containerFile: URL(fileURLWithPath: "/tmp/container.cdoc2"),
            fileManager: fileManager,
            containerUtil: containerUtil,
            dataFiles: dataFiles
        )
    }

    private func makeSourceFile(named name: String, contents: String) throws -> URL {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory())
            .appending(path: "CryptoContainerTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let file = directory.appending(path: name)
        try Data(contents.utf8).write(to: file)
        return file
    }

    @Test
    func addDataFiles_keepsSpecialSymbolsInTheFileName() async throws {
        let source = try makeSourceFile(named: "O&U #1 (100%) @2026 €5.txt", contents: "a")
        let container = makeContainer()

        try await container.addDataFiles([source])

        let names = await container.getDataFiles().map(\.lastPathComponent)
        #expect(names == ["O&U #1 (100%) @2026 €5.txt"])
    }

    @Test
    func addDataFiles_keepsUnicodeAndEmoji() async throws {
        let source = try makeSourceFile(named: "ää test ää 😀.txt", contents: "a")
        let container = makeContainer()

        try await container.addDataFiles([source])

        let names = await container.getDataFiles().map(\.lastPathComponent)
        #expect(names == ["ää test ää 😀.txt"])
    }

    @Test
    func addDataFiles_storesFileInsideContainerDirectoryWhenNameLooksLikeTraversal() async throws {
        let source = try makeSourceFile(named: "..to.txt", contents: "a")
        let container = makeContainer()

        try await container.addDataFiles([source])

        let cacheDirectory = try Directories.getCacheDirectory(
            subfolders: [Constants.Folder.ContainerFolder, Constants.Folder.Temp],
            fileManager: fileManager
        )
        let dataFiles = await container.getDataFiles()

        #expect(dataFiles.count == 1)
        #expect(dataFiles[0].isWithin(directory: cacheDirectory))
    }

    @Test
    func saveDataFile_returnsItsOwnBytesWhenTwoNamesSanitizeToTheSameName() async throws {
        let first = try makeSourceFile(named: "a<b.txt", contents: "first")
        let second = try makeSourceFile(named: "a>b.txt", contents: "second")
        let container = makeContainer(dataFiles: [first, second])

        let destination = URL(fileURLWithPath: NSTemporaryDirectory())
            .appending(path: "CryptoSaveTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)

        let savedFirst = try await container.saveDataFile(dataFile: first, to: destination)
        let savedSecond = try await container.saveDataFile(dataFile: second, to: destination)

        #expect(savedFirst != savedSecond)
        #expect(try String(contentsOf: savedFirst, encoding: .utf8) == "first")
        #expect(try String(contentsOf: savedSecond, encoding: .utf8) == "second")
    }

    @Test
    func saveDataFile_isIdempotentForRepeatedCalls() async throws {
        let file = try makeSourceFile(named: "report.pdf", contents: "content")
        let container = makeContainer(dataFiles: [file])

        let destination = URL(fileURLWithPath: NSTemporaryDirectory())
            .appending(path: "CryptoSaveTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)

        let firstCall = try await container.saveDataFile(dataFile: file, to: destination)
        let secondCall = try await container.saveDataFile(dataFile: file, to: destination)

        #expect(firstCall == secondCall)
        #expect(try String(contentsOf: secondCall, encoding: .utf8) == "content")
    }

    @Test(arguments: [
        ("report.pdf|123|application/pdf|D0", "report.pdf"),
        ("Q1|Q2 report.pdf|123|application/pdf|D0", "Q1|Q2 report.pdf"),
        ("a|b|c.txt|9|text/plain|D1", "a|b|c.txt")
    ])
    func cdocInfo_readsNamesContainingAPipe(origFile: String, expected: String) throws {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <denc:EncryptedData xmlns:denc="http://www.w3.org/2001/04/xmlenc#">
        <denc:EncryptionProperties>
        <denc:EncryptionProperty Name="DocumentFormat">ENCDOC-XML|1.1</denc:EncryptionProperty>
        <denc:EncryptionProperty Name="orig_file">\(origFile)</denc:EncryptionProperty>
        </denc:EncryptionProperties>
        </denc:EncryptedData>
        """

        let path = URL(fileURLWithPath: NSTemporaryDirectory())
            .appending(path: "cdocinfo-\(UUID().uuidString).cdoc")
        try xml.write(to: path, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: path) }

        let info = try CdocInfo(cdoc1Path: path.path(percentEncoded: false))

        #expect(info.dataFiles.map(\.filename) == [expected])
    }
}
