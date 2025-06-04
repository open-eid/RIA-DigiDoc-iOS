import Foundation
import LibdigidocLibSwift
import Testing
import CommonsTestShared

struct FileOpeningRepositoryTests {
    private var mockFileOpeningService: FileOpeningServiceProtocolMock!
    private var repository: FileOpeningRepositoryProtocol!

    init() async throws {
        mockFileOpeningService = FileOpeningServiceProtocolMock()
        repository = FileOpeningRepository(fileOpeningService: mockFileOpeningService)
    }

    @Test
    func isFileSizeValid_success() async throws {
        let tempFileURL = TestFileUtil.createSampleFile()

        mockFileOpeningService.isFileSizeValidHandler = { @Sendable _ in
            return true
        }

        let isValid = try await repository.isFileSizeValid(url: tempFileURL)

        defer {
            try? FileManager.default.removeItem(at: tempFileURL)
        }

        #expect(isValid)
        #expect(mockFileOpeningService.isFileSizeValidCallCount == 1)
        #expect(mockFileOpeningService.isFileSizeValidArgValues.first == tempFileURL)
    }

    @Test
    func getValidFiles_success() async throws {
        let tempFileURL = TestFileUtil.createSampleFile()

        let tempFileURL2 = TestFileUtil.createSampleFile()

        let fileURLs = [tempFileURL, tempFileURL2]

        mockFileOpeningService.getValidFilesHandler = { @Sendable _ in
            return fileURLs
        }

        let result: Result<[URL], any Error> = .success(fileURLs)
        let validFiles = try await repository.getValidFiles(result)

        #expect(validFiles == fileURLs)
        #expect(mockFileOpeningService.getValidFilesCallCount == 1)

        guard case let .success(validFilesResult) =
                mockFileOpeningService.getValidFilesArgValues.first,
              case let .success(expectedValidFiles) = result,
              validFilesResult == expectedValidFiles else {
            Issue.record("Expected to have file urls set")
            return
        }
    }

    @Test
    func openOrCreateContainer_success() async throws {
        let tempFileURL = TestFileUtil.createSampleFile()
        let tempFileURL2 = TestFileUtil.createSampleFile()

        let fileURLs = [tempFileURL, tempFileURL2]

        let signedContainer = SignedContainer()

        mockFileOpeningService.openOrCreateContainerHandler = { @Sendable _ in
            return signedContainer
        }

        let result = try await repository.openOrCreateContainer(urls: fileURLs)

        let signedContainerName = await signedContainer.getContainerName()
        let resultContainerName = await result.getContainerName()

        #expect(signedContainerName == resultContainerName)
        #expect(mockFileOpeningService.openOrCreateContainerCallCount == 1)
        #expect(mockFileOpeningService.openOrCreateContainerArgValues.first == fileURLs)
    }
}
