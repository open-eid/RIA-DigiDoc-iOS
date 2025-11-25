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
import CommonsTestShared
import CommonsLib
import CommonsLibMocks

@MainActor
class RecentDocumentsViewModelTests {
    private let mockSharedContainerViewModel: SharedContainerViewModelProtocolMock!
    private let mockFileManager: FileManagerProtocolMock!

    private let viewModel: RecentDocumentsViewModel!

    private let tempFolderURL: URL!

    init() async throws {
        mockSharedContainerViewModel = SharedContainerViewModelProtocolMock()
        mockFileManager = FileManagerProtocolMock()

        tempFolderURL = URL(fileURLWithPath: "/mock/path")

        viewModel = RecentDocumentsViewModel(
            sharedContainerViewModel: mockSharedContainerViewModel,
            fileManager: mockFileManager
        )
    }

    @Test
    func loadFiles_success() async {
        let file1 = tempFolderURL.appendingPathComponent("test1.asice")
        let file2 = tempFolderURL.appendingPathComponent("test2.bdoc")
        let invalidFile = tempFolderURL.appendingPathComponent("invalid.txt")

        mockFileManager.contentsOfDirectoryAtHandler = { _, _, _ in
            return [file1, file2, invalidFile]
        }

        mockFileManager.attributesOfItemHandler = { path in
            if path == file1.path || path == file2.path {
                return [.modificationDate: Date()]
            }

            throw NSError(domain: NSCocoaErrorDomain, code: NSFileReadNoSuchFileError, userInfo: nil)
        }

        mockFileManager.fileExistsAtPathHandler = { _, _ in true }

        viewModel.loadFiles(from: tempFolderURL, withExtensions: Constants.Container.ContainerExtensions)

        let files = viewModel.files

        let containsFile1 = files.contains { $0.url == file1 }
        let containsFile2 = files.contains { $0.url == file2 }
        let containsInvalidFile = files.contains { $0.url == invalidFile }

        #expect(files.count == 2)
        #expect(containsFile1)
        #expect(containsFile2)
        #expect(!containsInvalidFile)
    }

    @Test
    func loadFiles_emptyFilesWhenNoFolderLocation() async {
        let recentDocumentsViewModel = RecentDocumentsViewModel(
            sharedContainerViewModel: mockSharedContainerViewModel,
            fileManager: mockFileManager
        )

        recentDocumentsViewModel.loadFiles(from: tempFolderURL, withExtensions: Constants.Container.ContainerExtensions)

        let filesCount = recentDocumentsViewModel.files.count

        #expect(filesCount == 0)
    }

    @Test
    func loadFiles_emptyFilesWhenInvalidFolderLocation() async {
        let recentDocumentsViewModel = RecentDocumentsViewModel(
            sharedContainerViewModel: mockSharedContainerViewModel,
            fileManager: mockFileManager
        )

        recentDocumentsViewModel.loadFiles(from: tempFolderURL, withExtensions: Constants.Container.ContainerExtensions)

        let filesCount = recentDocumentsViewModel.files.count

        #expect(filesCount == 0)
    }

    @Test
    func filteredFiles_successWithFilteringContainerFiles() async {
        let date = Date()
        viewModel.files = [
            FileItem(name: "File1.asice", url: URL(fileURLWithPath: "file1.asice"), modifiedDate: date),
            FileItem(
                name: "File2.bdoc",
                url: URL(
                    fileURLWithPath: "file2.bdoc"
                ),
                modifiedDate: date.addingTimeInterval(
                    -1000
                )
            ),
            FileItem(name: "test.txt", url: URL(fileURLWithPath: "test.txt"), modifiedDate: date)
        ]
        viewModel.searchText = "file"

        let filteredFiles = viewModel.filteredFiles(using: Constants.Container.ContainerExtensions)

        #expect(filteredFiles.count == 2)
        #expect(filteredFiles[0].name == "File1.asice")
        #expect(filteredFiles[1].name == "File2.bdoc")
    }

    @Test
    func setChosenFiles_success() async {
        let mockFileURLs = [URL(fileURLWithPath: "file1.asice"), URL(fileURLWithPath: "file2.bdoc")]
        let result: Result<[URL], Error> = .success(mockFileURLs)

        mockSharedContainerViewModel.setFileOpeningResultHandler = { _ in }

        viewModel.setChosenFiles(result)

        #expect(mockSharedContainerViewModel.setFileOpeningResultCallCount == 1)

        guard case let .success(fileOpeningResultValue) =
                mockSharedContainerViewModel.setFileOpeningResultArgValues.first,
              case let .success(expectedUrls) = result,
              fileOpeningResultValue == expectedUrls else {
            Issue.record("Expected to have chosen files set")
            return
        }
    }

    @Test
    func deleteFile_success() {
        let file = tempFolderURL.appendingPathComponent("test1.asice")

        let fileItem = FileItem(name: "test1.asice", url: file, modifiedDate: Date())
        viewModel.files = [fileItem]

        mockFileManager.removeItemHandler = { _ in }

        viewModel.deleteFile(fileItem)

        #expect(mockFileManager.removeItemCallCount == 1)
        #expect(mockFileManager.removeItemArgValues.first == file)
        #expect(viewModel.files.isEmpty)
    }

    @Test
    func deleteFile_filesNotChangedWhenUnableToDelete() async {
        let file = tempFolderURL.appendingPathComponent("test1.asice")
        let fileItem = FileItem(name: "test1.asice", url: file, modifiedDate: Date())
        viewModel.files = [fileItem]

        mockFileManager.removeItemHandler = { _ in
            throw NSError(domain: NSCocoaErrorDomain, code: NSFileNoSuchFileError, userInfo: nil)
        }

        viewModel.deleteFile(fileItem)

        #expect(mockFileManager.removeItemCallCount == 1)
        #expect(viewModel.files.count == 1)
        #expect(viewModel.files.contains { $0.url == file })
    }
}
