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

struct ContainerUtilTests {

    private let mockFileManager: FileManagerProtocolMock!

    private let containerUtil: ContainerUtil

    init() async throws {
        mockFileManager = FileManagerProtocolMock()

        containerUtil = ContainerUtil(fileManager: mockFileManager)
    }

    @Test
    func getSignatureContainerFile_successWithFileNameWithoutChanges() async {
        let tempDirectory = URL(fileURLWithPath: "/tmp")
        let uniqueFileName = "file-\(UUID().uuidString).txt"
        let fileURL = tempDirectory.appending(path: uniqueFileName)

        let uniqueFileURL = containerUtil.getContainerFile(
            for: fileURL,
            in: tempDirectory
        )

        #expect(uniqueFileName == uniqueFileURL.lastPathComponent)
    }

    @Test
    func getSignatureContainerFile_successWithOneExistingFile() async {
        let tempDirectory = URL(fileURLWithPath: "/tmp")

        let uniqueFileName = "file-\(UUID().uuidString).txt"
        let fileURL = tempDirectory.appending(path: uniqueFileName)

        let existingPaths: Set<String> = [
            fileURL.resolvedPath,
            tempDirectory.appending(path: "\(uniqueFileName).txt").resolvedPath
        ]

        mockFileManager.fileExistsHandler = { path in
            return existingPaths.contains(path)
        }

        let uniqueFileURL = containerUtil.getContainerFile(
            for: fileURL,
            in: tempDirectory
        )

        #expect(uniqueFileURL.lastPathComponent == "\(fileURL.deletingPathExtension().lastPathComponent) (1).txt")
    }

    @Test
    func getSignatureContainerFile_successWithMultipleExistingFile() async {
        let tempDirectory = URL(fileURLWithPath: "/tmp")

        let uniqueFileName = "file-\(UUID().uuidString)"
        let fileURL = tempDirectory.appending(path: "\(uniqueFileName).txt")

        let existingPaths: Set<String> = [
            fileURL.resolvedPath,
            tempDirectory.appending(path: "\(uniqueFileName) (1).txt").resolvedPath,
            tempDirectory.appending(path: "\(uniqueFileName) (2).txt").resolvedPath
        ]

        mockFileManager.fileExistsHandler = { path in
            return existingPaths.contains(path)
        }

        let uniqueFileURL = containerUtil.getContainerFile(
            for: fileURL,
            in: tempDirectory
        )

        #expect(uniqueFileURL.lastPathComponent == "\(fileURL.deletingPathExtension().lastPathComponent) (3).txt")
    }

    @Test
    func getSignatureContainerFile_successWithNoFileExtension() async {
        let tempDirectory = URL(fileURLWithPath: "/tmp")
        let uniqueFileName = "file-\(UUID().uuidString)"
        let fileURL = tempDirectory.appending(path: uniqueFileName)

        let existingPaths: Set<String> = [
            fileURL.resolvedPath
        ]

        mockFileManager.fileExistsHandler = { path in
            existingPaths.contains(path)
        }

        let uniqueFileURL = containerUtil.getContainerFile(
            for: fileURL,
            in: tempDirectory
        )

        #expect(uniqueFileURL.lastPathComponent == "\(uniqueFileName) (1)")
    }

    @Test
    func getSignatureContainerFile_successWithDifferentSymbols() async {
        let tempDirectory = URL(fileURLWithPath: "/tmp")

        let uniqueFileName = "file-name_with.symbols-\(UUID().uuidString).txt"
        let fileURL = tempDirectory.appending(path: uniqueFileName)

        let existingPaths: Set<String> = [
            fileURL.resolvedPath,
            tempDirectory.appending(path: "\(uniqueFileName).txt").resolvedPath
        ]

        mockFileManager.fileExistsHandler = { path in
            return existingPaths.contains(path)
        }

        let uniqueFileURL = containerUtil.getContainerFile(
            for: fileURL,
            in: tempDirectory
        )

        #expect(uniqueFileURL.lastPathComponent == "\(fileURL.deletingPathExtension().lastPathComponent) (1).txt")
    }

    @Test
    func getSignatureContainersDir_success() throws {
        let cachesDir = URL(fileURLWithPath: "/mock/cache")
        let expectedDir = cachesDir
            .appending(path: BundleUtil.getBundleIdentifier())
            .appending(path: Constants.Folder.SignedContainerFolder)

        mockFileManager.urlHandler = { directory, _, _, _ in
            #expect(directory == .cachesDirectory)
            return cachesDir
        }
        mockFileManager.createDirectoryHandler = { _, _, _ in }

        let signatureContainersDir = try containerUtil.getSignatureContainersDir()

        #expect(signatureContainersDir.resolvedPath == expectedDir.resolvedPath)
    }

    @Test
    func getSignatureContainersDir_throwErrorWhenCreatingContainerDoesNotSucceed() throws {
        let cachesDir = URL(fileURLWithPath: "/mock/cache")

        mockFileManager.urlHandler = { directory, _, _, _ in
            #expect(directory == .cachesDirectory)
            return cachesDir
        }
        mockFileManager.createDirectoryHandler = { _, _, _ in
            throw URLError(.unknown)
        }

        #expect(throws: URLError.self) {
            _ = try containerUtil.getSignatureContainersDir()
        }
    }

    @Test
    func getContainerDataFilesDir_returnDirectoryWhenFileInSignatureDirAndUseCacheDir() throws {
        let cachesDir = URL(fileURLWithPath: "/mock/cache")
        let signatureDir = cachesDir.appending(path: Constants.Folder.SignedContainerFolder)
        let containerFile = signatureDir.appending(path: "file.asice")
        let expectedDataDir = cachesDir
            .appending(path: Constants.Folder.SignedContainerFolder)
            .appending(path: "file.asice-data-files")

        mockFileManager.urlHandler = { _, _, _, _ in cachesDir }
        mockFileManager.urlsHandler = { _, _ in [cachesDir] }
        mockFileManager.fileExistsHandler = { _ in false }

        mockFileManager.createDirectoryHandler = { _, _, _ in }

        let containerDataFilesDir = try containerUtil.getContainerDataFilesDir(containerFile: containerFile)

        #expect(containerDataFilesDir.resolvedPath == expectedDataDir.resolvedPath)
    }

    @Test
    func getContainerDataFilesDir_returnDirectoryWhenOutsideSignatureDirAndUseContainerParentDir() throws {
        let cachesDir = URL(fileURLWithPath: "/mock/cache")

        let containerDir = URL(fileURLWithPath: "/some/other")
        let containerFile = containerDir.appending(path: "otherfile.asice")
        let expectedDataDir = containerDir.appending(path: "otherfile.asice-data-files")

        mockFileManager.urlsHandler = { _, _ in [cachesDir] }

        mockFileManager.fileExistsHandler = { _ in false }

        mockFileManager.createDirectoryHandler = { _, _, _ in }

        let containerDataFilesDir = try containerUtil.getContainerDataFilesDir(containerFile: containerFile)

        #expect(containerDataFilesDir.resolvedPath == expectedDataDir.resolvedPath)
    }
}
