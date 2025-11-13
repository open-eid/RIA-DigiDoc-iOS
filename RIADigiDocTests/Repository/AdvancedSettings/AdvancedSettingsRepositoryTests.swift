/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
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

import CommonsLib
import CommonsLibMocks
import CommonsTestShared
import Foundation
import Testing

struct AdvancedSettingsRepositoryTests {
    private let mockFileManager: FileManagerProtocolMock
    private let mockCertificateUtil: CertificateUtilProtocolMock

    private let repository: AdvancedSettingsRepositoryProtocol!

    init() async throws {
        mockFileManager = FileManagerProtocolMock()
        mockCertificateUtil = CertificateUtilProtocolMock()

        repository = AdvancedSettingsRepository(
            fileManager: mockFileManager,
            certificateUtil: mockCertificateUtil
        )
    }

    // MARK: - GetCertificate Tests

    @Test
    func getCertificate_success() async throws {
        let sampleFileURL = TestCertificateUtil.createSampleCertFile()
        let sampleFileBaseName = sampleFileURL.deletingPathExtension().lastPathComponent
        let sampleFolder = sampleFileURL
            .deletingPathExtension().deletingPathExtension().lastPathComponent
        defer {
            try? FileManager.default.removeItem(at: sampleFileURL)
        }

        mockFileManager.contentsOfDirectoryAtHandler = { _, _, _ in
            return [
                sampleFileURL
            ]
        }
        mockFileManager.fileExistsHandler = { _ in
            return true
        }

        let certificateData = await repository.getCertificate(
            certificateFolder: sampleFolder,
            certificateBaseName: sampleFileBaseName,
        )

        #expect(certificateData != nil)
    }

    @Test
    func getCertificate_returnsNilWhenFileDoesNotExist() async throws {
        let sampleFileBaseName = "test-name"
        let sampleFolder = "test-folder"

        mockFileManager.contentsOfDirectoryAtHandler = { _, _, _ in
            return [
            ]
        }
        mockFileManager.fileExistsHandler = { _ in
            return false
        }

        let certificateData = await repository.getCertificate(
            certificateFolder: sampleFolder,
            certificateBaseName: sampleFileBaseName,
        )

        #expect(certificateData == nil)
    }

    @Test
    func getCertificate_doesNotThrowWhenGetCertificateFileURLThrows() async throws {
        let sampleFileURL = TestCertificateUtil.createSampleCertFile()
        let sampleFileBaseName = sampleFileURL.deletingPathExtension().lastPathComponent
        let sampleFolder = sampleFileURL
            .deletingPathExtension().deletingPathExtension().lastPathComponent
        defer {
            try? FileManager.default.removeItem(at: sampleFileURL)
        }

        mockFileManager.fileExistsHandler = { _ in
            return true
        }
        mockFileManager.contentsOfDirectoryAtHandler = { _, _, _ in
            throw NSError(domain: "TestError", code: 1, userInfo: nil)
        }

        await #expect(throws: Never.self) {
            let certificateData = await repository.getCertificate(
                certificateFolder: sampleFolder,
                certificateBaseName: sampleFileBaseName,
            )
            #expect(certificateData == nil)
        }
    }

    // MARK: - importCertificate tests

    @Test
    func importCertificate_success() async throws {
        let sampleFileURL = TestCertificateUtil.createSampleCertFile(
            subfolder: BundleUtil.getBundleIdentifier()
        )
        let sampleFileBaseName = sampleFileURL.deletingPathExtension().lastPathComponent
        let sampleFileFolder = sampleFileURL.deletingLastPathComponent().deletingLastPathComponent()
        defer {
            try? FileManager.default.removeItem(at: sampleFileURL)
        }

        mockFileManager.urlHandler = { _, _, _, _ in
            return sampleFileFolder
        }

        let certificateData = await repository.importCertificate(
            from: sampleFileURL,
            certificateFolder: "",
            certificateBaseName: sampleFileBaseName,
        )

        #expect(certificateData != nil)
        #expect(mockFileManager.copyItemCallCount == 1)
    }

    @Test
    func importCertificate_doesNotThrowWhenCreateDirectoryThrows() async throws {
        let sampleFileURL = TestCertificateUtil.createSampleCertFile()
        let sampleFileBaseName = sampleFileURL.deletingPathExtension().lastPathComponent
        defer {
            try? FileManager.default.removeItem(at: sampleFileURL)
        }

        mockFileManager.createDirectoryHandler = { _, _, _ in
            throw NSError(domain: "TestError", code: 1, userInfo: nil)
        }

        await #expect(throws: Never.self) {
            let certificateData = await repository.importCertificate(
                from: sampleFileURL,
                certificateFolder: "test-folder",
                certificateBaseName: sampleFileBaseName,
            )
            #expect(certificateData == nil)
        }
    }

    @Test
    func importCertificate_doesNotThrowWhenRemoveAllCertFilesThrows() async throws {
        let sampleFileURL = TestCertificateUtil.createSampleCertFile()
        let sampleFileBaseName = sampleFileURL.deletingPathExtension().lastPathComponent
        defer {
            try? FileManager.default.removeItem(at: sampleFileURL)
        }

        mockFileManager.contentsOfDirectoryAtHandler = { _, _, _ in
            return [
                sampleFileURL
            ]
        }
        mockFileManager.fileExistsHandler = { _ in
            return true
        }
        mockFileManager.removeItemHandler = { _ in
            throw NSError(domain: "TestError", code: 1, userInfo: nil)
        }

        await #expect(throws: Never.self) {
            let certificateData = await repository.importCertificate(
                from: sampleFileURL,
                certificateFolder: "test-folder",
                certificateBaseName: sampleFileBaseName,
            )
            #expect(certificateData == nil)
        }
    }

    // MARK: - removeAllCertFiles tests

    @Test
    func removeAllCertFiles_success() async throws {
        let sampleFileURL = URL(fileURLWithPath: "/test/path/folder/file.cer")
        let sampleFileFolder = URL(fileURLWithPath: "/test/path/folder")

        mockFileManager.contentsOfDirectoryAtHandler = { _, _, _ in
            [sampleFileURL]
        }

        mockFileManager.urlHandler = { _, _, _, _ in
            return sampleFileFolder
        }

        try await repository.removeAllCertFiles(certificateFolders: [
            sampleFileFolder.lastPathComponent,
            sampleFileFolder.lastPathComponent
        ])
        #expect(mockFileManager.removeItemCallCount == 2)
    }

    @Test
    func removeAllCertFiles_doesNotThrowWithNoFolders() async throws {
        await #expect(throws: Never.self) {
            try await repository.removeAllCertFiles(certificateFolders: [])
            #expect(mockFileManager.removeItemCallCount == 0)
        }
    }
}
