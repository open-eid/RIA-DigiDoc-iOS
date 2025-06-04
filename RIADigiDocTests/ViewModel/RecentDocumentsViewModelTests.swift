import Foundation
import Testing

@MainActor
class RecentDocumentsViewModelTests {
    private var mockSharedContainerViewModel: SharedContainerViewModelProtocolMock!

    private let viewModel: RecentDocumentsViewModel!

    private let tempFolderURL: URL!

    init() async throws {
        mockSharedContainerViewModel = SharedContainerViewModelProtocolMock()

        tempFolderURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempFolderURL, withIntermediateDirectories: true)

        viewModel = RecentDocumentsViewModel(
            sharedContainerViewModel: mockSharedContainerViewModel,
            folderURL: tempFolderURL
        )
    }

    deinit {
        try? FileManager.default.removeItem(at: tempFolderURL)
    }

    @Test
    func loadFiles_success() async {
        let file1 = tempFolderURL.appendingPathComponent("test1.asice")
        let file2 = tempFolderURL.appendingPathComponent("test2.bdoc")
        let invalidFile = tempFolderURL.appendingPathComponent("invalid.txt")

        try? "content".write(to: file1, atomically: true, encoding: .utf8)
        try? "content".write(to: file2, atomically: true, encoding: .utf8)
        try? "content".write(to: invalidFile, atomically: true, encoding: .utf8)
        try? FileManager.default.setAttributes([.modificationDate: Date()], ofItemAtPath: file1.path)

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
        try? "content".write(to: file, atomically: true, encoding: .utf8)
        viewModel.files = [FileItem(name: "test1.asice", url: file, modifiedDate: Date())]

        viewModel.deleteFile(at: IndexSet(integer: 0))

        #expect(!viewModel.files.contains { $0.url == file })
        #expect(!FileManager.default.fileExists(atPath: file.path))
    }

    @Test
    @MainActor
    func deleteFile_filesNotChangedWhenUnableToDelete() async {
        let file = tempFolderURL.appendingPathComponent("test1.asice")
        viewModel.files = [FileItem(name: "test1.asice", url: file, modifiedDate: Date())]

        viewModel.deleteFile(at: IndexSet(integer: 0))

        #expect(viewModel.files.count == 1)
        #expect(viewModel.files.contains { $0.url == file })
    }
}
