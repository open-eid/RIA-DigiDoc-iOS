import Foundation
import Testing
import FactoryKit
import FactoryTesting
import LibdigidocLibSwift
import CommonsLib
import UtilsLib
import CommonsTestShared
import CommonsLibMocks
import UtilsLibMocks

struct FileOpeningServiceTests {
    private let mockFileUtil: FileUtilProtocolMock
    private let mockFileManager: FileManagerProtocolMock
    private let mockFileInspector: FileInspectorProtocolMock

    private var service: FileOpeningServiceProtocol

    init() throws {
        mockFileUtil = FileUtilProtocolMock()
        mockFileManager = FileManagerProtocolMock()
        mockFileInspector = FileInspectorProtocolMock()

        service = FileOpeningService(
            fileUtil: mockFileUtil,
            fileInspector: mockFileInspector,
            fileManager: mockFileManager
        )
    }

    func isFileSizeValid_success() async throws {
        let tempURL = URL(fileURLWithPath: mockFileManager.temporaryDirectory.resolvingSymlinksInPath().path + "/tmp")
        let tempFileURL = tempURL.appendingPathComponent("test.txt")

        mockFileInspector.fileSizeHandler = { _ in 100 }

        let isValid = try await service.isFileSizeValid(url: tempFileURL)

        #expect(isValid)
    }

    @Test
    func isFileSizeValid_throwInvalidFileSizeErrorWhenFileSizeIsZero() async throws {
        let tempURL = URL(fileURLWithPath: mockFileManager.temporaryDirectory.resolvingSymlinksInPath().path + "/tmp")
        let tempFileURL = tempURL.appendingPathComponent("test.txt")

        mockFileInspector.fileSizeHandler = { _ in
            throw FileOpeningError.invalidFileSize
        }

        do {
            _ = try await service.isFileSizeValid(url: tempFileURL)
            Issue.record("Expected 'invalidFileSize' error")
            return
        } catch let error {
            switch error as? FileOpeningError {
            case .invalidFileSize:
                #expect(true)
            default:
                Issue.record("Expected 'invalidFileSize' error")
                return
            }
        }

        try? FileManager.default.removeItem(at: tempFileURL)
    }

    @Test
    func getValidFiles_success() async throws {
        let tempURL = URL(fileURLWithPath: mockFileManager.temporaryDirectory.resolvingSymlinksInPath().path + "/tmp")
        let tempFileURL = tempURL.appendingPathComponent("test.txt")
        let tempFileURL2 = tempURL.appendingPathComponent("test2.txt")

        let urls = [tempFileURL, tempFileURL2]

        let result: Result<[URL], Error> = .success(urls)

        mockFileUtil.getValidFileInAppHandler = { _ in tempURL }

        mockFileManager.urlsHandler = { _, _ in [tempURL] }
        mockFileManager.contentsOfDirectoryAtHandler = { _, _, _ in [tempFileURL, tempFileURL2] }
        mockFileInspector.fileSizeHandler = { _ in 100 }

        let validFiles = try await service.getValidFiles(result)

        #expect(validFiles.count == 2)
    }

    @Test
    func getValidFiles_successWithDuplicateFiles() async throws {
        let tempURL = URL(fileURLWithPath: mockFileManager.temporaryDirectory.resolvingSymlinksInPath().path + "/tmp")
        let tempFileURL = tempURL.appendingPathComponent("test.txt")

        let urls = [tempFileURL, tempFileURL]

        let result: Result<[URL], Error> = .success(urls)

        mockFileUtil.getValidFileInAppHandler = { _ in tempURL }

        mockFileManager.urlsHandler = { _, _ in [tempURL] }
        mockFileManager.contentsOfDirectoryAtHandler = { _, _, _ in [tempFileURL, tempFileURL] }
        mockFileInspector.fileSizeHandler = { _ in 100 }

        let validFiles = try await service.getValidFiles(result)

        #expect(validFiles.count == 2)
    }

    @Test
    func getValidFiles_throwErrorWhenResultUnsuccessful() async throws {
        let testError = NSError(domain: "Test", code: 1, userInfo: nil)
        let result: Result<[URL], Error> = .failure(testError)

        do {
            _ = try await service.getValidFiles(result)
            Issue.record("Expected error to be thrown")
            return
        } catch let error {
            #expect(testError.domain == (error as NSError).domain)
            #expect(testError.code == (error as NSError).code)
            #expect(testError.userInfo.keys == (error as NSError).userInfo.keys)
        }
    }

    @Test
    func openOrCreateContainer_success() async throws {
        let tempFileURL = TestFileUtil.createSampleFile()
        let tempFileURL2 = TestFileUtil.createSampleFile()
        let urls = [tempFileURL, tempFileURL2]

        let container = try await service.openOrCreateContainer(dataFiles: urls)

        defer {
            try? FileManager.default.removeItem(at: tempFileURL)
            try? FileManager.default.removeItem(at: tempFileURL2)
        }

        let containerName = await container.getContainerName()

        #expect(!containerName.isEmpty)
    }

    @Test
    func openOrCreateContainer_throwErrorWhenDatafilesEmpty() async throws {
        let emptyURLs: [URL] = []

        do {
            _ = try await service.openOrCreateContainer(dataFiles: emptyURLs)
            Issue.record("Expected 'containerCreationFailed' error")
            return
        } catch let error {
            switch error as? DigiDocError {
            case .containerCreationFailed(let errorDetail):
                #expect(errorDetail.message == "Cannot create or open container. Datafiles are empty")
            default:
                Issue.record("Expected 'containerCreationFailed' error")
                return
            }
        }
    }
}
