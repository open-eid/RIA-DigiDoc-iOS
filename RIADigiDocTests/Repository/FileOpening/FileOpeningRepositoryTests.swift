import Foundation
import Testing
import LibdigidocLibSwift
import CommonsTestShared
import UtilsLibMocks
import CommonsLibMocks

struct FileOpeningRepositoryTests {
    private let mockFileManager: FileManagerProtocolMock
    private let mockContainerUtil: ContainerUtilProtocolMock
    private let mockFileOpeningService: FileOpeningServiceProtocolMock!

    private let repository: FileOpeningRepositoryProtocol!

    init() async throws {
        mockFileManager = FileManagerProtocolMock()
        mockContainerUtil = ContainerUtilProtocolMock()
        mockFileOpeningService = FileOpeningServiceProtocolMock()

        repository = FileOpeningRepository(fileOpeningService: mockFileOpeningService)
    }

    @Test
    func isFileSizeValid_success() async throws {
        let tempFileURL = URL(fileURLWithPath: "/mock/path/test.txt")

        mockFileOpeningService.isFileSizeValidHandler = { _ in
            return true
        }

        let isValid = try await repository.isFileSizeValid(url: tempFileURL)

        #expect(isValid)
        #expect(mockFileOpeningService.isFileSizeValidCallCount == 1)
        #expect(mockFileOpeningService.isFileSizeValidArgValues.first == tempFileURL)
    }

    @Test
    func getValidFiles_success() async throws {
        let tempFileURL = URL(fileURLWithPath: "/mock/path/test.txt")

        let tempFileURL2 = URL(fileURLWithPath: "/mock/path/test2.txt")

        let fileURLs = [tempFileURL, tempFileURL2]

        mockFileOpeningService.getValidFilesHandler = { _ in
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
        let tempFileURL = URL(fileURLWithPath: "/mock/path/test.txt")
        let tempFileURL2 = URL(fileURLWithPath: "/mock/path/test2.txt")

        let fileURLs = [tempFileURL, tempFileURL2]

        let signedContainer = SignedContainer(
            fileManager: mockFileManager,
            containerUtil: mockContainerUtil
        )

        mockFileOpeningService.openOrCreateContainerHandler = { _ in
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
