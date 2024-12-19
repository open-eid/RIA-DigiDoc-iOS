import Foundation
import Testing
import Cuckoo
import LibdigidocLibSwift
import CommonsTestShared

final class FileOpeningServiceTests {
    private var service: FileOpeningServiceProtocol!

    init() async throws {
        service = await FileOpeningService()
    }

    deinit {
        service = nil
    }

    @Test
    func isFileSizeValid_success() async throws {
        let tempFileURL = TestFileUtil.createSampleFile()

        let isValid = try await service.isFileSizeValid(url: tempFileURL)

        defer {
            try? FileManager.default.removeItem(at: tempFileURL)
        }

        #expect(isValid)
    }

    @Test
    func isFileSizeValid_throwInvalidFileSizeErrorWhenFileSizeIsZero() async throws {
        let tempFileURL = TestFileUtil.createSampleFile(
            name: "zeroByteFile",
            withExtension: "txt",
            contents: nil
        )

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
        let tempFileURL = TestFileUtil.createSampleFile()

        let tempFileURL2 = TestFileUtil.createSampleFile()

        let urls = [tempFileURL, tempFileURL2]

        let result: Result<[URL], Error> = .success(urls)

        let validFiles = try await service.getValidFiles(result)

        defer {
            try? FileManager.default.removeItem(at: tempFileURL)
            try? FileManager.default.removeItem(at: tempFileURL2)
        }

        #expect(2 == validFiles.count)
    }

    @Test
    func getValidFiles_successWithDuplicateFiles() async throws {
        let tempFileURL = TestFileUtil.createSampleFile()

        let urls = [tempFileURL, tempFileURL]

        let result: Result<[URL], Error> = .success(urls)

        let validFiles = try await service.getValidFiles(result)

        defer {
            try? FileManager.default.removeItem(at: tempFileURL)
        }

        #expect(2 == validFiles.count)
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
                #expect("Cannot create or open container. Datafiles are empty" == errorDetail.message)
            default:
                Issue.record("Expected 'containerCreationFailed' error")
                return
            }
        }
    }
}
