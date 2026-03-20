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
import LibdigidocLibSwift
import CommonsLib
import UtilsLib
import CommonsTestShared
import CommonsLibMocks
import LibdigidocLibSwiftMocks

@MainActor
struct DataFilesViewModelTests {

    var viewModel: DataFilesViewModel!
    var mockSharedContainerViewModel: SharedContainerViewModelProtocolMock
    var mockFileManager: FileManagerProtocolMock

    init() async throws {
        mockSharedContainerViewModel = SharedContainerViewModelProtocolMock()
        mockFileManager = FileManagerProtocolMock()
        viewModel = DataFilesViewModel(
            sharedContainerViewModel: mockSharedContainerViewModel,
            fileManager: mockFileManager
        )
    }

    @Test
    func saveDataFile_success() async throws {
        let fileURL = URL(fileURLWithPath: "/mock/path/test.txt")
        let dataFile = MockDataFileWrapper.mockDataFileWrapper(
            fileId: "D1",
            fileName: fileURL.lastPathComponent,
            fileSize: 1,
            mediaType: CommonsLib.Constants.MimeType.Default
        )

        let mockSignedContainer = SignedContainerProtocolMock()

        mockSharedContainerViewModel.currentContainerHandler = { mockSignedContainer }

        mockSignedContainer.getDataFilesHandler = { [dataFile] }

        mockSignedContainer.saveDataFileHandler = { _, _ in fileURL }

        guard let firstDataFile = await mockSignedContainer.getDataFiles().first else {
            Issue.record("Unable to get data file")
            return
        }

        let result = await viewModel.saveDataFile(dataFile: firstDataFile)

        #expect(fileURL.lastPathComponent == result?.lastPathComponent)
        #expect(mockSharedContainerViewModel.currentContainerCallCount == 1)
    }

    @Test
    func saveDataFile_returnNilWhenDataFileDoesNotExist() async throws {
        let nonExistingFileURL = URL(fileURLWithPath: "/mock/path/nonexistent.txt")
        let dataFile = MockDataFileWrapper.mockDataFileWrapper(
            fileId: "D1",
            fileName: nonExistingFileURL.lastPathComponent,
            fileSize: 1,
            mediaType: CommonsLib.Constants.MimeType.Default
        )

        let mockSignedContainer = SignedContainerProtocolMock()

        mockSharedContainerViewModel.currentContainerHandler = { mockSignedContainer }
        mockSignedContainer.getDataFilesHandler = { [] }
        mockSignedContainer.saveDataFileHandler = { _, _ in
            throw DigiDocError.containerDataFileSavingFailed(
                ErrorDetail(
                    message: "File does not exist",
                    code: 1,
                    userInfo: [:]
                )
            )
        }

        let result = await viewModel.saveDataFile(dataFile: dataFile)

        #expect(result == nil)
        #expect(mockSharedContainerViewModel.currentContainerCallCount == 1)
    }

    @Test
    func checkIfContainerFileExists_returnTrueWhenFileExists() async {
        let fileURL = URL(fileURLWithPath: "/mock/path/test.txt")

        mockFileManager.fileExistsHandler = { _ in true }

        let result = viewModel.checkIfContainerFileExists(fileLocation: fileURL)

        #expect(result)
    }

    @Test
    func checkIfContainerFileExists_returnFalseWhenFileDoesNotExist() async {
        let nonExistingFileURL = URL(fileURLWithPath: "/mock/path/nonexistent.txt")

        let result = viewModel.checkIfContainerFileExists(fileLocation: nonExistingFileURL)

        #expect(!result)
    }

    @Test
    func checkIfContainerFileExists_returnNilWithNilInput() async {
        let result = viewModel.checkIfContainerFileExists(fileLocation: nil)

        #expect(!result)
    }

    @Test
    func removeSavedFilesDirectory_successReturningFalseAfterRemovingDirectory() async {
        let directoryURL = URL(fileURLWithPath: "/mock/path")

        mockFileManager.removeItemHandler = { _ in }
        mockFileManager.fileExistsHandler = { _ in false }

        viewModel.removeSavedFilesDirectory(savedFilesDirectory: directoryURL)

        #expect(!mockFileManager.fileExists(atPath: directoryURL.resolvedPath))
        #expect(mockFileManager.removeItemCallCount == 1)
    }

    @Test
    func removeSavedFilesDirectory_returnFalseWhenDirectoryDoesNotExist() async {
        let nonExistingDirectoryURL = URL(fileURLWithPath: "/mock/nonexistingpath/")

        mockFileManager.fileExistsHandler = { _ in false }

        viewModel.removeSavedFilesDirectory(savedFilesDirectory: nonExistingDirectoryURL)

        #expect(!mockFileManager.fileExists(atPath: nonExistingDirectoryURL.resolvedPath))
    }
}
