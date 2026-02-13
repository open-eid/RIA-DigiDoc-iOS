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

import Foundation
import Testing
import CommonsLib
import CommonsTestShared
import CommonsLibMocks

@testable import UtilsLib

struct DirectoriesTests {

    private let mockFileManager: FileManagerProtocolMock!

    private var testLibraryDirectory: URL!
    private var testCacheDirectory: URL!

    init() async throws {
        mockFileManager = FileManagerProtocolMock()
    }

    @Test
    func getTempDirectory_createDirectory() async throws {
        let tempDirectory = URL(fileURLWithPath: "/tmp")
        let subfolder = "testSubfolder"
        let expectedURL = tempDirectory
            .appending(path: BundleUtil.getBundleIdentifier(), directoryHint: .isDirectory)
            .appending(path: subfolder, directoryHint: .isDirectory)

        mockFileManager.temporaryDirectory = tempDirectory
        mockFileManager.fileExistsHandler = { _ in false }

        let resultURL = try Directories.getTempDirectory(subfolder: subfolder, fileManager: mockFileManager)

        #expect(resultURL.resolvedPath == expectedURL.resolvedPath)
        #expect(mockFileManager.createDirectoryCallCount == 1)
    }

    @Test
    func getTempDirectory_doesntCreateDirectoryWhenExists() async throws {
        let tempDirectory = URL(fileURLWithPath: "/tmp")
        let subfolder = "existingTestSubfolder"
        let expectedURL = tempDirectory
            .appending(path: BundleUtil.getBundleIdentifier(), directoryHint: .isDirectory)
            .appending(path: subfolder, directoryHint: .isDirectory)

        mockFileManager.temporaryDirectory = tempDirectory
        mockFileManager.fileExistsHandler = { _ in true }

        let resultURL = try Directories.getTempDirectory(subfolder: subfolder, fileManager: mockFileManager)

        #expect(resultURL.resolvedPath == expectedURL.resolvedPath)
        #expect(mockFileManager.createDirectoryCallCount == 0)
    }

    @Test
    func getSharedFolder_returnCorrectURLWhenFolderExists() async throws {
        guard let sharedContainerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: Constants.Identifier.Group
        ) else {
            Issue.record("Expected valid shared container URL")
            return
        }

        let testSubFolder = "TestFolder"
        let expectedFolderURL = sharedContainerURL.appending(path: testSubFolder)

        mockFileManager.containerURLHandler = { _ in sharedContainerURL }
        mockFileManager.fileExistsHandler = { _ in true }

        let result = try Directories.getSharedFolder(
            subfolder: testSubFolder,
            fileManager: mockFileManager
        )

        #expect(expectedFolderURL.standardizedFileURL == result.standardizedFileURL)
        #expect(mockFileManager.createDirectoryCallCount == 0)
    }

    @Test
    func getSharedFolder_createAndReturnCorrectURLWhenFolderDoesNotExist() async throws {
        guard let sharedContainerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: Constants.Identifier.Group
        ) else {
            Issue.record("Expected valid shared container URL")
            return
        }

        let testSubFolder = "TestFolder-\(UUID().uuidString)"
        let expectedFolderURL = sharedContainerURL.appending(path: testSubFolder)

        mockFileManager.containerURLHandler = { _ in sharedContainerURL }
        mockFileManager.fileExistsHandler = { _ in false }

        let result = try Directories.getSharedFolder(
            subfolder: testSubFolder,
            fileManager: mockFileManager
        )

        #expect(expectedFolderURL.standardizedFileURL == result.standardizedFileURL)
        #expect(mockFileManager.createDirectoryCallCount == 1)
    }

    @Test
    func getSharedFolder_throwErrorWhenContainerURLDoesNotExist() async {

        let emptyAppGroupIdentifier = ""

        mockFileManager.containerURLHandler = { _ in nil }

        do {
            _ = try Directories.getSharedFolder(appGroupIdentifier: emptyAppGroupIdentifier,
                                                fileManager: mockFileManager)
            Issue.record("Expected .fileDoesNotExist error")
            return
        } catch let error as URLError {
            #expect(error.code == .fileDoesNotExist)
        } catch {
            Issue.record("Expected .fileDoesNotExist error")
            return
        }
    }

    @Test
    func getCacheDirectory_returnCorrectPath() async throws {
        let cacheDirectory = URL(fileURLWithPath: "/cache")
        let subfolder = "TestFolder"
        let expectedDir = cacheDirectory
            .appending(path: BundleUtil.getBundleIdentifier())
            .appending(path: subfolder, directoryHint: .isDirectory)

        mockFileManager.urlHandler = { _, _, _, _ in cacheDirectory }
        mockFileManager.fileExistsHandler = { _ in true }

        let directory = try Directories.getCacheDirectory(
            subfolders: [subfolder],
            fileManager: mockFileManager
        )

        #expect(expectedDir == directory)
        #expect(mockFileManager.createDirectoryCallCount == 0)
    }

    @Test
    func getCacheDirectory_createDirectoryIfNotExists() async throws {
        let cacheDirectory = URL(fileURLWithPath: "/cache")
        let subfolder = "NewTestFolder"
        let expectedDir = cacheDirectory
            .appending(path: BundleUtil.getBundleIdentifier())
            .appending(path: subfolder, directoryHint: .isDirectory)

        mockFileManager.urlHandler = { _, _, _, _ in cacheDirectory }
        mockFileManager.fileExistsHandler = { _ in false }

        let directory = try Directories.getCacheDirectory(
            subfolders: [subfolder],
            fileManager: mockFileManager
        )

        #expect(expectedDir == directory)
        #expect(mockFileManager.createDirectoryCallCount == 1)
    }

    @Test
    func getCacheDirectory_returnDirectoryWithoutSubfolder() async throws {
        let cacheDirectory = URL(fileURLWithPath: "/cache")
        let expectedDir = cacheDirectory
            .appending(path: BundleUtil.getBundleIdentifier(), directoryHint: .isDirectory)

        mockFileManager.urlHandler = { _, _, _, _ in cacheDirectory }
        mockFileManager.fileExistsHandler = { _ in true }

        let directory = try Directories.getCacheDirectory(fileManager: mockFileManager)

        #expect(expectedDir.resolvedPath == directory.resolvedPath)
        #expect(mockFileManager.createDirectoryCallCount == 0)
    }

    @Test
    func getCacheDirectory_doesNotRecreateExistingDirectory() async throws {
        let baseCacheURL = URL(fileURLWithPath: "/mock/cache")
        let existingFolderURL = baseCacheURL
            .appending(path: BundleUtil.getBundleIdentifier(), directoryHint: .isDirectory)
            .appending(path: "existingFolder", directoryHint: .isDirectory)

        mockFileManager.urlHandler = { _, _, _, _ in
            return baseCacheURL
        }

        mockFileManager.fileExistsHandler = { path in
            return path == existingFolderURL.resolvedPath
        }

        let result = try Directories.getCacheDirectory(
            subfolders: ["existingFolder"],
            fileManager: mockFileManager
        )

        #expect(result.resolvedPath == existingFolderURL.resolvedPath)
        #expect(mockFileManager.createDirectoryCallCount == 0)
    }

    @Test
    func getLibraryDirectory_success() async throws {
        let mockDirectory = URL(fileURLWithPath: "mock/library/directory")

        mockFileManager.urlsHandler = { _, _ in
            return [URL(fileURLWithPath: "mock/library/directory")]
        }

        let directory = Directories.getLibraryDirectory(fileManager: mockFileManager)

        #expect(mockDirectory == directory)
    }

    @Test
    func getLogsDirectory_primaryDirectoryExists() throws {
        let mockDirectory = URL(fileURLWithPath: "/path/to/primary/directory")
        let expectedDirectory = mockDirectory.appending(path: CommonsLib.Constants.Folder.Logs)

        let trimmedExpectedDirectoryPath = expectedDirectory.resolvedPath.hasPrefix("/") ? String(
            expectedDirectory.resolvedPath.dropFirst()
        ) : expectedDirectory.resolvedPath

        mockFileManager.fileExistsHandler = { _ in true }

        mockFileManager.createDirectoryHandler = { _, _, _ in }

        let logFilePath = try Directories.getLibdigidocLogFile(
            from: mockDirectory,
            fileManager: mockFileManager
        )

        let trimmedLogFilePath = expectedDirectory.resolvedPath.hasPrefix("/") ? String(
            expectedDirectory.resolvedPath.dropFirst()
        ) : expectedDirectory.resolvedPath

        #expect(logFilePath != nil)
        #expect(trimmedExpectedDirectoryPath == trimmedLogFilePath)
        #expect("libdigidocpp.log" == logFilePath?.lastPathComponent)
    }

    @Test
    func getLogsDirectory_mainDirectoryDoesNotExistButFallbackDirectoryExists() async throws {

        mockFileManager.fileExistsHandler = { _ in false }

        let logFilePath = try Directories.getLibdigidocLogFile(from: nil, fileManager: mockFileManager)

        #expect(logFilePath != nil)
        #expect("libdigidocpp.log" == logFilePath?.lastPathComponent)
    }

    @Test
    func getDocumentsDirectory_success() async throws {
        let mockDirectory = URL(fileURLWithPath: "mock/documents/directory")

        mockFileManager.urlsHandler = { _, _ in
            return [URL(fileURLWithPath: "mock/documents/directory")]
        }

        let directory = Directories.getDocumentsDirectory(fileManager: mockFileManager)

        #expect(mockDirectory == directory)
    }

    @Test
    func getDocumentsDirectory_returnNilWhenDocumentsFolderDoesNotExist() async throws {

        mockFileManager.urlsHandler = { _, _ in
            return []
        }

        let directory = Directories.getDocumentsDirectory(fileManager: mockFileManager)

        #expect(directory == nil)
    }

    @Test
    func getApplicationDirectory_success() async throws {
        let mockDirectory = URL(fileURLWithPath: "mock/application/directory")

        mockFileManager.urlsHandler = { _, _ in
            return [URL(fileURLWithPath: "mock/application/directory")]
        }

        let directory = Directories.getApplicationDirectory(fileManager: mockFileManager)

        #expect(mockDirectory == directory)
    }

    @Test
    func getApplicationDirectory_returnNilWhenDocumentsFolderDoesNotExist() async throws {

        mockFileManager.urlsHandler = { _, _ in
            return []
        }

        let directory = Directories.getApplicationDirectory(fileManager: mockFileManager)

        #expect(directory == nil)
    }
}
