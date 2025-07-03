import Foundation
import Testing
import UniformTypeIdentifiers
import FactoryKit
import FactoryTesting
import CommonsLib
import CommonsTestShared
import CommonsLibMocks

@testable import FileImportShareExtension

private let isLiveWebsiteTestsEnabled = false

@MainActor
struct ShareViewModelTests {
    private static let remoteURLForTestFile = "https://localhost/test.txt"

    private let mockFileManager: FileManagerProtocolMock!
    private let mockUrlResourceChecker: URLResourceCheckerProtocolMock!
    private let viewModel: ShareViewModel!

    init() async throws {
        let fileManagerMock = FileManagerProtocolMock()
        let urlResourceCheckerMock = URLResourceCheckerProtocolMock()

        self.mockFileManager = fileManagerMock
        self.mockUrlResourceChecker = urlResourceCheckerMock
        self.viewModel = ShareViewModel(fileManager: fileManagerMock, resourceChecker: mockUrlResourceChecker)
    }

    @Test
    func importFiles_success() async {
        let fileUrl = URL(fileURLWithPath: "/mock/path/to/file.txt")
        let fileUrl2 = URL(fileURLWithPath: "/mock/path/to/file2.txt")

        let fileItem = ImportedFileItem(
            fileUrl: fileUrl,
            filename: fileUrl.lastPathComponent,
            data: Data(),
            typeIdentifier: .data
        )

        let fileItem2 = ImportedFileItem(
            fileUrl: fileUrl2,
            filename: fileUrl2.lastPathComponent,
            data: Data(),
            typeIdentifier: .data
        )

        mockFileManager.containerURLHandler = { _ in fileUrl }
        mockFileManager.fileExistsHandler = { _ in true }
        mockUrlResourceChecker.checkResourceIsReachableHandler = { _ in true }

        let result = await viewModel.importFiles([fileItem, fileItem2])

        #expect(result)
        #expect(Status.imported == viewModel.status)
    }

    @Test
    func importFiles_returnFalseWhenNoInputItems() async {
        let fileUrl = URL(fileURLWithPath: "")

        let fileItem = ImportedFileItem(
            fileUrl: fileUrl,
            filename: "",
            data: Data(),
            typeIdentifier: .data
        )

        mockUrlResourceChecker.checkResourceIsReachableHandler = { _ in false }

        let result = await viewModel.importFiles([fileItem])

        #expect(!result)
        #expect(Status.failed == viewModel.status)
    }

    @Test
    func importFiles_returnFalseWhenInvalidInputItem() async {
        let fileUrl = URL(fileURLWithPath: "test")

        let fileItem = ImportedFileItem(
            fileUrl: fileUrl,
            filename: "",
            data: Data(),
            typeIdentifier: .data
        )

        mockUrlResourceChecker.checkResourceIsReachableHandler = { _ in false }

        let result = await viewModel.importFiles([fileItem])

        #expect(!result)
        #expect(Status.failed == viewModel.status)
    }

    @Test
    func cacheItem_success() async throws {
        let fileUrl = URL(fileURLWithPath: "/mock/path/to/file.txt")
        let fileUrl2 = URL(fileURLWithPath: "/mock/path/to/file2.txt")

        let fileItem = ImportedFileItem(
            fileUrl: fileUrl,
            filename: fileUrl.lastPathComponent,
            data: Data(),
            typeIdentifier: .data
        )

        let fileItem2 = ImportedFileItem(
            fileUrl: fileUrl2,
            filename: fileUrl2.lastPathComponent,
            data: Data(),
            typeIdentifier: .data
        )

        mockFileManager.containerURLHandler = { _ in fileUrl }
        mockFileManager.fileExistsHandler = { _ in true }
        mockUrlResourceChecker.checkResourceIsReachableHandler = { _ in true }

        let result = try await viewModel.cacheItem(
            itemIndex: 0,
            providerIndex: 0,
            items: [fileItem, fileItem2]
        )

        #expect(result)
    }

    @Test
    func cacheItem_returnTrueWhenNoMoreItemsToCache() async throws {
        let result = try await viewModel.cacheItem(
            itemIndex: 0,
            providerIndex: 0,
            items: []
        )

        #expect(result)
    }

    @Test
    func cacheItem_returnTrueWhenNoItemsToCache() async throws {
        let result = try await viewModel.cacheItem(
            itemIndex: 1,
            providerIndex: 0,
            items: []
        )

        #expect(result)
    }

    @Test
    func cacheFileForProvider_success() async throws {
        let fileItem = ImportedFileItem(
            fileUrl: URL(fileURLWithPath: "/mock/path/to/file.txt"),
            filename: "file.txt",
            data: Data(),
            typeIdentifier: .data
        )

        mockFileManager.containerURLHandler = { _ in fileItem.fileUrl }
        mockFileManager.fileExistsHandler = { _ in true }
        mockUrlResourceChecker.checkResourceIsReachableHandler = { _ in true }

        let result = try await viewModel.cacheFileForProvider(fileItem: fileItem)

        #expect(result)
    }

    @Test
    func cacheFileOnUrl_success() async {
        let fileItem = ImportedFileItem(
            fileUrl: URL(fileURLWithPath: "/mock/path/to/file.txt"),
            filename: "file.txt",
            data: Data(),
            typeIdentifier: .data
        )

        mockFileManager.containerURLHandler = { _ in fileItem.fileUrl }
        mockFileManager.fileExistsHandler = { _ in true }
        mockUrlResourceChecker.checkResourceIsReachableHandler = { _ in true }

        let result = await viewModel.cacheFileOnUrl(fileItem.fileUrl)

        #expect(result)
    }

    @Test(.enabled(if: isLiveWebsiteTestsEnabled))
    func cacheFileOnUrl_successWithRemoteUrl() async {
        guard let remoteFileURL = URL(string: ShareViewModelTests.remoteURLForTestFile) else {
            Issue.record("Unable to create URL object")
            return
        }

        let result = await viewModel.cacheFileOnUrl(remoteFileURL)

        #expect(result)
    }

    @Test
    func cacheFileOnUrl_returnFalseWithInvalidUrl() async {
        guard let remoteFileURL = URL(string: "wrong_url") else {
            Issue.record("Unable to create URL object")
            return
        }

        let result = await viewModel.cacheFileOnUrl(remoteFileURL)

        #expect(!result)
    }

    @Test
    func cacheFileOnUrl_returnFalseWithInvalidFileUrl() async {
        guard let remoteFileURL = URL(string: "file:///wrong_url") else {
            Issue.record("Unable to create URL object")
            return
        }

        let result = await viewModel.cacheFileOnUrl(remoteFileURL)

        #expect(!result)
    }

    @Test(.enabled(if: isLiveWebsiteTestsEnabled))
    func downloadFileFromUrl_successWithRemoteUrl() async {
        guard let remoteFileURL = URL(string: ShareViewModelTests.remoteURLForTestFile) else {
            Issue.record("Unable to create URL object")
            return
        }

        let result = await viewModel.downloadFileFromUrl(remoteFileURL)

        #expect(result)
    }

    @Test
    func downloadFileFromUrl_returnFalseWithInvalidUrl() async {
        guard let remoteFileURL = URL(string: "https://wrong_url") else {
            Issue.record("Unable to create URL object")
            return
        }

        let result = await viewModel.downloadFileFromUrl(remoteFileURL)

        #expect(!result)
    }

    private func createTemporaryFile2(contents: String = "Test data") -> URL {
        let tempDirectoryURL = FileManager.default.temporaryDirectory
        let tempFileURL = tempDirectoryURL.appendingPathComponent(UUID().uuidString)
        try? contents.write(to: tempFileURL, atomically: true, encoding: .utf8)
        return tempFileURL
    }

    private func createTestExtensionItem(with fileURL: URL) -> NSExtensionItem {
        let extensionItem = NSExtensionItem()
        let provider = NSItemProvider(contentsOf: fileURL)
        extensionItem.attachments = [provider].compactMap { $0 }
        return extensionItem
    }
}
