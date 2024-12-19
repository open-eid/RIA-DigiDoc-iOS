import Foundation
import Testing
import UniformTypeIdentifiers
import Cuckoo
import CommonsTestShared

@testable import FileImportShareExtension

@MainActor
final class ShareViewModelTests {
    private static let isLiveWebsiteTestsEnabled = false
    private static let remoteURLForTestFile = "https://localhost/test.txt"

    private var viewModel: ShareViewModel!

    init() async throws {
        viewModel = ShareViewModel()
    }

    deinit {
        viewModel = nil
    }

    @Test
    func importFiles_success() async {
        let extensionContext = TestExtensionContext(
            inputItems: [createTestExtensionItem(
                with: TestFileUtil.createSampleFile()
            )]
        )

        let result = await viewModel.importFiles(extensionContext: extensionContext)

        #expect(result)
        #expect(Status.imported == viewModel.status)
    }

    @Test
    func importFiles_returnFalseWhenNoInputItems() async {
        let extensionContext = TestExtensionContext(inputItems: [])

        let result = await viewModel.importFiles(extensionContext: extensionContext)

        #expect(!result)
        #expect(Status.failed == viewModel.status)
    }

    @Test
    func importFiles_returnFalseWhenExtensionContextNil() async {

        let result = await viewModel.importFiles(extensionContext: nil)

        #expect(!result)
        #expect(Status.failed == viewModel.status)
    }

    @Test
    func importFiles_returnFalseWhenInvalidInputItem() async {
        let extensionContext = TestExtensionContext(inputItems: ["test"])

        let result = await viewModel.importFiles(extensionContext: extensionContext)

        #expect(!result)
        #expect(Status.failed == viewModel.status)
    }

    @Test
    func importFiles_returnFalseWhenInvalidItemProvider() async throws {
        let provider = NSItemProvider(item: "InvalidObject" as NSString, typeIdentifier: UTType.data.identifier)

        let extensionItem = NSExtensionItem()
        extensionItem.attachments = [provider].compactMap { $0 }

        let result = await viewModel
            .importFiles(
                extensionContext: TestExtensionContext(inputItems: [extensionItem])
            )

        #expect(!result)
        #expect(Status.failed == viewModel.status)
    }

    @Test
    func cacheItem_success() async throws {
        let result = try await viewModel.cacheItem(
            itemIndex: 0,
            providerIndex: 0,
            items: [createTestExtensionItem(
                with: TestFileUtil.createSampleFile()
            )]
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
        let temporaryFileURL = TestFileUtil.createSampleFile()
        let provider = NSItemProvider(contentsOf: temporaryFileURL)

        let result = try await viewModel.cacheFileForProvider(provider: provider)

        #expect(result)
    }

    @Test(.enabled(if: isLiveWebsiteTestsEnabled))
    func cacheFileForProvider_successWithURL() async throws {
        guard let url = URL(string: ShareViewModelTests.remoteURLForTestFile) else {
            Issue.record("Unable to create URL object")
            return
        }

        let provider = NSItemProvider(object: url as NSURL)

        let result = try await viewModel.loadItem(for: provider, typeIdentifier: UTType.url.identifier)

        #expect(result != nil)
    }

    @Test
    func cacheFileForProvider_successWithData() async throws {
        let temporaryFileURL = TestFileUtil.createSampleFile()

        guard let provider = NSItemProvider(contentsOf: temporaryFileURL) else {
            Issue.record("Unable to create NSItemProvider object")
            return
        }

        let result = try await viewModel.loadItem(for: provider, typeIdentifier: UTType.data.identifier)

        #expect(result != nil)
    }

    @Test
    func cacheFileForProvider_returnFalseWhenProviderNil() async throws {
        let result = try await viewModel.cacheFileForProvider(provider: nil)

        #expect(!result)
    }

    @Test
    func loadItem_throwInvalidItemDataErrorWhenInvalidItemForUrlIdentifier() async {
        let provider = NSItemProvider(item: String() as NSSecureCoding, typeIdentifier: UTType.url.identifier)

        do {
            _ = try await viewModel.loadItem(for: provider, typeIdentifier: UTType.url.identifier)
            Issue.record("Expected 'invalidItemData'error")
            return
        } catch let error as FileImportError {
            #expect(.invalidItemData == error)
        } catch {
            Issue.record("Unexpected error type: \(error)")
            return
        }
    }

    @Test
    func loadItem_throwInvalidItemDataErrorWhenInvalidItemForDataIdentifier() async {
        let invalidObject = "InvalidObject"
        let provider = NSItemProvider(item: invalidObject as NSString, typeIdentifier: UTType.data.identifier)

        do {
            _ = try await viewModel.loadItem(for: provider, typeIdentifier: UTType.data.identifier)
            Issue.record("Expected 'invalidItemData' error")
            return
        } catch let error as FileImportError {
            #expect(.invalidItemData == error)
        } catch {
            Issue.record("Unexpected error type: \(error)")
            return
        }
    }

    @Test
    func loadItem_throwInvalidItemDataErrorWhenInvalidUrlForDataIdentifier() async {
        guard let url = URL(string: "https://someUrl") else {
            Issue.record("Unable to create URL object")
            return
        }

        let provider = NSItemProvider(item: url as NSSecureCoding, typeIdentifier: UTType.data.identifier)

        do {
            _ = try await viewModel.loadItem(for: provider, typeIdentifier: UTType.data.identifier)
            Issue.record("Expected 'loadError' error")
            return
        } catch let error as FileImportError {
            switch error {
            case .loadError:
                #expect(true)
            default:
                Issue.record("Unexpected error type: \(error)")
                return
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
            return
        }
    }

    @Test
    func cacheFileOnUrl_success() async {
        let temporaryFileURL = TestFileUtil.createSampleFile()

        let result = await viewModel.cacheFileOnUrl(temporaryFileURL)

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

/// Custom subclass of NSExtensionContext for testing
final class TestExtensionContext: NSExtensionContext {
    private let testInputItems: [Any]

    init(inputItems: [Any]) {
        self.testInputItems = inputItems
        super.init()
    }

    override var inputItems: [Any] {
        return testInputItems
    }
}
