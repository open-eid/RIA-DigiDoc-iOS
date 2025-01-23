import Foundation
import Testing
import Cuckoo

class RecentDocumentsViewModelTests {
    private var mockSharedContainerViewModel: MockSharedContainerViewModel!

    private var viewModel: RecentDocumentsViewModel!

    private var tempFolderURL: URL!

    init() async throws {
        mockSharedContainerViewModel = MockSharedContainerViewModel()

        tempFolderURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempFolderURL, withIntermediateDirectories: true)

        viewModel = await RecentDocumentsViewModel(
            sharedContainerViewModel: mockSharedContainerViewModel,
            folderURL: tempFolderURL
        )
    }

    deinit {
        try? FileManager.default.removeItem(at: tempFolderURL)
        mockSharedContainerViewModel = nil
        viewModel = nil
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

        await viewModel.loadFiles()

        let filesCount = await viewModel.files.count

        #expect(2 == filesCount)
        await #expect(viewModel.files.contains { $0.url == file1 })
        await #expect(viewModel.files.contains { $0.url == file2 })
        await #expect(!viewModel.files.contains { $0.url == invalidFile })
    }

    @Test
    func loadFiles_emptyFilesWhenNoFolderLocation() async {
        let recentDocumentsViewModel = await RecentDocumentsViewModel(
            sharedContainerViewModel: mockSharedContainerViewModel,
            folderURL: nil
        )

        await recentDocumentsViewModel.loadFiles()

        let filesCount = await recentDocumentsViewModel.files.count

        #expect(0 == filesCount)
    }

    @Test
    func loadFiles_emptyFilesWhenInvalidFolderLocation() async {
        let recentDocumentsViewModel = await RecentDocumentsViewModel(
            sharedContainerViewModel: mockSharedContainerViewModel,
            folderURL: URL(fileURLWithPath: "/invalid/path")
        )

        await recentDocumentsViewModel.loadFiles()

        let filesCount = await recentDocumentsViewModel.files.count

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

        #expect(2 == filteredFiles.count)
        #expect("File1.asice" == filteredFiles[0].name)
        #expect("File2.bdoc" == filteredFiles[1].name)
    }

    @Test
    func setChosenFiles_success() async {
        let mockFileURLs = [URL(fileURLWithPath: "file1.asice"), URL(fileURLWithPath: "file2.bdoc")]
        let result: Result<[URL], Error> = .success(mockFileURLs)

        stub(mockSharedContainerViewModel) { mock in
            when(mock.setFileOpeningResult(fileOpeningResult: any())).then { receivedResult in
                guard case let .success(receivedURLs) = receivedResult else {
                    Issue.record("Expected a successful result")
                    return
                }
                #expect(mockFileURLs == receivedURLs)
            }
        }

        await viewModel.setChosenFiles(result)

        verify(mockSharedContainerViewModel).setFileOpeningResult(fileOpeningResult: any())
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

        #expect(1 == viewModel.files.count)
        #expect(viewModel.files.contains { $0.url == file })
    }
}
