import Foundation
import CommonsTestShared
import Testing

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
            folderURL: tempFolderURL,
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

        viewModel.loadFiles()

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
            folderURL: nil
        )

        recentDocumentsViewModel.loadFiles()

        let filesCount = recentDocumentsViewModel.files.count

        #expect(filesCount == 0)
    }

    @Test
    func loadFiles_emptyFilesWhenInvalidFolderLocation() async {
        let recentDocumentsViewModel = RecentDocumentsViewModel(
            sharedContainerViewModel: mockSharedContainerViewModel,
            folderURL: URL(fileURLWithPath: "/invalid/path")
        )

        recentDocumentsViewModel.loadFiles()

        let filesCount = recentDocumentsViewModel.files.count

        #expect(filesCount == 0)
    }

    @Test
    @MainActor
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

        let filteredFiles = viewModel.filteredFiles

        #expect(filteredFiles.count == 2)
        #expect(filteredFiles[0].name == "File1.asice")
        #expect(filteredFiles[1].name == "File2.bdoc")
    }

    @Test
    func setChosenFiles_success() async {
        let mockFileURLs = [URL(fileURLWithPath: "file1.asice"), URL(fileURLWithPath: "file2.bdoc")]
        let result: Result<[URL], Error> = .success(mockFileURLs)

        mockSharedContainerViewModel.setFileOpeningResultHandler = { @Sendable _ in }

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
    @MainActor
    func deleteFile_success() async {
        let file = tempFolderURL.appendingPathComponent("test1.asice")

        var mockFiles: Set<URL> = [file]

        mockFileManager.removeItemHandler = { url in
            guard mockFiles.contains(url) else {
                throw NSError(domain: NSCocoaErrorDomain, code: NSFileNoSuchFileError, userInfo: nil)
            }
            mockFiles.remove(url)
        }

        viewModel.files = [FileItem(name: "test1.asice", url: file, modifiedDate: Date())]

        viewModel.deleteFile(at: IndexSet(integer: 0))

        #expect(!viewModel.files.contains { $0.url == file })
        #expect(!mockFiles.contains(file))
    }

    @Test
    @MainActor
    func deleteFile_filesNotChangedWhenUnableToDelete() async {
        let file = tempFolderURL.appendingPathComponent("test1.asice")
        viewModel.files = [FileItem(name: "test1.asice", url: file, modifiedDate: Date())]

        mockFileManager.removeItemHandler = { _ in
            throw NSError(domain: NSCocoaErrorDomain, code: NSFileNoSuchFileError, userInfo: nil)
        }

        viewModel.deleteFile(at: IndexSet(integer: 0))

        #expect(mockFileManager.removeItemCallCount == 1)
        #expect(viewModel.files.count == 1)
        #expect(viewModel.files.contains { $0.url == file })
    }
}
