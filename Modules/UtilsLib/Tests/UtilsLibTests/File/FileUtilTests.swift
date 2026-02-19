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
import FactoryKit
import FactoryTesting
import ZIPFoundation
import CommonsLib
import CommonsTestShared
import CommonsLibMocks

@testable import UtilsLib

struct FileUtilTests {

    private let mockFileManager: FileManagerProtocolMock
    private let fileUtil: FileUtilProtocol

    init() async throws {
        self.mockFileManager = FileManagerProtocolMock()
        self.fileUtil = FileUtil(fileManager: mockFileManager)
    }

    @Test
    func getMimeTypeFromZipFile_returnCorrectMimeType() async throws {
        let asiceMimetype = CommonsLib.Constants.MimeType.Asice
        let zipFileURL = try TestContainerUtil.createMockContainer(
            with: ["mimetype": asiceMimetype],
            containerExtension: "zip")

        mockFileManager.createDirectoryHandler = { url, _, _ in
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }

        guard let sharedContainerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: Constants.Identifier.Group
        ) else {
            Issue.record("Expected a valid shared container URL")
            return
        }

        mockFileManager.temporaryDirectory = sharedContainerURL

        mockFileManager.containerURLHandler = { _ in sharedContainerURL }

        defer {
            try? FileManager.default.removeItem(at: zipFileURL)
            try? FileManager.default.removeItem(
                at: mockFileManager.temporaryDirectory.appending(path: "com.apple.dt.xctest.tool")
            )
        }

        let fileNameToFind = "mimetype"

        let fileFromZip = try #require(await fileUtil.getFileFromZipFile(
            from: zipFileURL,
            fileNameToFind: fileNameToFind
        ))

        let mimetypeContent = try String(contentsOf: fileFromZip, encoding: .utf8)
        let mimetype = mimetypeContent.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        #expect(asiceMimetype == mimetype)
    }

    @Test
    func getMimeTypeFromZipFile_returnNilWhenFileDoesNotExist() async throws {
        let zipFileURL = try TestContainerUtil.createMockContainer(
            with: [:],
            containerExtension: "zip")

        let fileNameToFind = "nonexistentfile.txt"

        let mimeType = try await fileUtil.getFileFromZipFile(
            from: zipFileURL,
            fileNameToFind: fileNameToFind
        )

        #expect(mimeType == nil)

        try FileManager.default.removeItem(at: zipFileURL)
    }

    @Test
    func getValidPath_successWithAppContainerPath() async throws {
        let appContainerFileURL = URL(fileURLWithPath: "/var/mobile/Containers/Data/Application/mockFile.txt")

        let result = await fileUtil.getValidPath(url: appContainerFileURL)

        #expect(result == appContainerFileURL)
    }

    @Test
    func getValidPath_successWithMailUrl() async throws {
        let mailFileURL = URL(fileURLWithPath: "/var/mobile/Library/Mail")

        let result = await fileUtil.getValidPath(url: mailFileURL)

        #expect(result == mailFileURL)
    }

    @Test
    func getValidPath_returnNilWhenFileNotInDirectories() async throws {
        if !SystemUtil.isSimulator {
            let nonExistentFileURL = URL(fileURLWithPath: "someFolder")

            let result = await fileUtil.getValidPath(url: nonExistentFileURL)

            #expect(result == nil)
        }
    }

    @Test
    func getFileUrlFromAppGroup_returnNilWhenFileNotInAppGroup() async throws {
        let groupIdentifier = Constants.Identifier.Group
        let nonExistentFileURL = URL(fileURLWithPath: "/mock/nonExistent/path/file.txt")

        guard let sharedContainerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: groupIdentifier
        ) else {
            Issue.record("Expected a valid shared container URL")
            return
        }

        mockFileManager.containerURLHandler = { _ in sharedContainerURL }

        let result = fileUtil.getFileUrlFromAppGroup(nonExistentFileURL, appGroupIdentifier: groupIdentifier)

        #expect(result == nil)
    }

    @Test
    func isFileInsideMailFolder_successWithFileInsideMailSubfolder() async throws {
        let url = URL(fileURLWithPath: "/var/mobile/Library/Mail/Inbox/message.eml")
        let isFileInsideMailFolder = fileUtil.isFileInsideMailFolder(url)
        #expect(isFileInsideMailFolder)
    }

    @Test
    func isFileInsideMailFolder_successWithTrailingSlash() async throws {
        let url = URL(fileURLWithPath: "/var/mobile/Library/Mail/")
        let isFileInsideMailFolder = fileUtil.isFileInsideMailFolder(url)
        #expect(isFileInsideMailFolder)
    }

    @Test
    func isFileInsideMailFolder_returnFalseWhenFileOutsideMailFolder() async throws {
        let url = URL(fileURLWithPath: "/var/mobile/Library/OtherApp/file.txt")
        let isFileInsideMailFolder = fileUtil.isFileInsideMailFolder(url)
        #expect(!isFileInsideMailFolder)
    }

    @Test
    func getAllFileURLs_success() async throws {
        let folderURL = URL(fileURLWithPath: "/mock/folder")
        let expectedFiles = [
            URL(fileURLWithPath: "/mock/folder/file1.txt"),
            URL(fileURLWithPath: "/mock/folder/file2.txt")
        ]

        mockFileManager.contentsOfDirectoryAtHandler = { _, _, _ in expectedFiles }

        let result = fileUtil.getAllFileURLs(from: folderURL)

        #expect(result == expectedFiles)
    }

    @Test
    func getAllFileURLs_successWhenFolderIsEmpty() async throws {
        let folderURL = URL(fileURLWithPath: "/mock/empty")

        mockFileManager.contentsOfDirectoryAtHandler = { _, _, _ in [] }

        let result = fileUtil.getAllFileURLs(from: folderURL)

        #expect(result.isEmpty)
    }

    @Test
    func getAllFileURLs_returnEmptyArrayWhenUnableToGetContentsOfFolderDirectory() async throws {
        let folderURL = URL(fileURLWithPath: "/mock/error")

        mockFileManager.contentsOfDirectoryAtHandler = { _, _, _ in
            throw NSError(domain: "TestError", code: 1)
        }

        let result = fileUtil.getAllFileURLs(from: folderURL)

        #expect(result.isEmpty)
    }

    @Test
    func removeSharedFiles_success() async throws {
        let sharedFolderURL = URL(fileURLWithPath: "/mock/shared")
        let files = [
            sharedFolderURL.appending(path: "file1.txt"),
            sharedFolderURL.appending(path: "file2.txt")
        ]

        mockFileManager.contentsOfDirectoryAtHandler = { _, _, _ in files }
        mockFileManager.fileExistsAtPathHandler = { path, isDirectoryPtr in
            if path == sharedFolderURL.resolvedPath {
                isDirectoryPtr?.pointee = ObjCBool(true)
                return true
            }
            return false
        }

        try fileUtil.removeSharedFiles(url: sharedFolderURL)

        #expect(mockFileManager.removeItemArgValues == files)
    }

    @Test
    func removeSharedFiles_throwErrorWhenUnableToRemoveItem() async throws {
        let sharedFolderURL = URL(fileURLWithPath: "/mock/shared")
        let files = [
            sharedFolderURL.appending(path: "file1.txt"),
            sharedFolderURL.appending(path: "file2.txt")
        ]

        mockFileManager.contentsOfDirectoryAtHandler = { _, _, _ in files }
        mockFileManager.fileExistsAtPathHandler = { path, isDirectoryPtr in
            if path == sharedFolderURL.resolvedPath {
                isDirectoryPtr?.pointee = ObjCBool(true)
                return true
            }
            return false
        }

        mockFileManager.removeItemHandler = { _ in
            throw NSError(domain: "TestError", code: 1)
        }

        do {
            try fileUtil.removeSharedFiles(url: sharedFolderURL)
            Issue.record("Expected to throw an error")
            return
        } catch {
            #expect(true)
        }
    }

    @Test
    func removeSharedFiles_doesntRemoveAnythingWhenNoFilesInDirectory() async throws {
        let sharedFolderURL = URL(fileURLWithPath: "/mock/shared")

        mockFileManager.contentsOfDirectoryAtHandler = { _, _, _ in [] }

        try fileUtil.removeSharedFiles(url: sharedFolderURL)

        #expect(mockFileManager.removeItemCallCount == 0)
    }

    @Test
    func fileExists_returnTrueIfFileExists() async throws {
        let testDirectory = URL(fileURLWithPath: "/tmp")
        let testFile = testDirectory.appending(path: "testFile.asice")

        mockFileManager.fileExistsHandler = { _ in true }

        let containerFileExists = fileUtil.fileExists(fileLocation: testFile)
        #expect(containerFileExists)
    }

    @Test
    func fileExists_returnFalseIfFileDoesNotExist() async throws {
        let testDirectory = URL(fileURLWithPath: "/tmp")
        let nonExistentFile = testDirectory.appending(path: "nonExistent.asice")

        mockFileManager.fileExistsHandler = { _ in false }

        let containerFileExists = fileUtil.fileExists(fileLocation: nonExistentFile)
        #expect(!containerFileExists)
    }

    @Test
    func fileExists_returnFalseWithNilInput() async {
        let containerFileExists = fileUtil.fileExists(fileLocation: nil)
        #expect(!containerFileExists)
    }

    @Test
    func removeSavedFilesDirectory_successWhenDirectoryExists() async throws {
        let testDirectory = URL(fileURLWithPath: "/tmp")
        let savedFilesDirectory = testDirectory.appending(path: Constants.Folder.SavedFiles)

        mockFileManager.fileExistsHandler = { path in
            return path == savedFilesDirectory.resolvedPath
        }

        #expect(mockFileManager.fileExists(atPath: savedFilesDirectory.resolvedPath))

        fileUtil.removeSavedFilesDirectory(savedFilesDirectory: savedFilesDirectory)

        #expect(mockFileManager.removeItemCallCount == 1)
    }

    @Test
    func removeSavedFilesDirectory_doesNotThrowErrorWhenRemovingDirectoryAndItDoesntExist() async {
        let testDirectory = URL(fileURLWithPath: "/tmp")
        let nonExistentDirectory = testDirectory.appending(path: "NonExistentDir")

        #expect(throws: Never.self) {
            self.fileUtil.removeSavedFilesDirectory(savedFilesDirectory: nonExistentDirectory)
        }

        #expect(!mockFileManager.fileExists(atPath: nonExistentDirectory.resolvedPath))
    }

    @Test
    func removeCacheLogsDirectory_successWhenDirectoryExists() async throws {
        fileUtil.removeCacheLogsDirectory()

        #expect(mockFileManager.removeItemCallCount == 1)
    }

    @Test
    func removeCacheLogsDirectory_doesNotThrowWhenDirectoryCreationFails() async throws {
        mockFileManager.createDirectoryHandler = { _, _, _ in
            throw NSError(domain: "TestError", code: 1)
        }

        #expect(throws: Never.self) {
            fileUtil.removeCacheLogsDirectory()
        }

        #expect(mockFileManager.removeItemCallCount == 0)
    }

    @Test
    func removeCacheLogsDirectory_doesNotThrowErrorWhenRemovingDirectoryAndItDoesntExist() async throws {
        mockFileManager.removeItemHandler = { _ in
            throw NSError(domain: "TestError", code: 1)
        }

        #expect(throws: Never.self) {
            fileUtil.removeCacheLogsDirectory()
        }

        #expect(mockFileManager.removeItemCallCount == 1)
    }

    @Test
    func removeLibraryLogsDirectory_successWhenDirectoryExists() async throws {
        let testDirectory = URL(fileURLWithPath: "/tmp")
        fileUtil.removeLibraryLogsDirectory(directory: testDirectory)

        #expect(mockFileManager.removeItemCallCount == 1)
    }
}
