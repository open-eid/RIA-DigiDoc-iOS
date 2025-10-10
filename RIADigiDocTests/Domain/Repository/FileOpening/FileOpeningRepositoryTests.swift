import Foundation
import Testing
import LibdigidocLibSwift
import CommonsTestShared
import UtilsLibMocks
import CommonsLibMocks

struct FileOpeningRepositoryTests {
    private let mockFileManager: FileManagerProtocolMock
    private let mockContainerUtil: ContainerUtilProtocolMock
    private let mockFileOpeningService: FileOpeningServiceProtocolMock
    private let mockSivaService: SivaServiceProtocolMock

    private let repository: FileOpeningRepositoryProtocol!

    init() async throws {
        mockFileManager = FileManagerProtocolMock()
        mockContainerUtil = ContainerUtilProtocolMock()
        mockFileOpeningService = FileOpeningServiceProtocolMock()
        mockSivaService = SivaServiceProtocolMock()

        repository = FileOpeningRepository(
            fileOpeningService: mockFileOpeningService, sivaService: mockSivaService
        )
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

        mockFileOpeningService.openOrCreateContainerHandler = { _, _ in
            return signedContainer
        }

        let result = try await repository.openOrCreateContainer(
            urls: fileURLs, isSivaConfirmed: true
        )

        let signedContainerName = await signedContainer.getContainerName()
        let resultContainerName = await result.getContainerName()

        #expect(signedContainerName == resultContainerName)
        #expect(mockFileOpeningService.openOrCreateContainerCallCount == 1)
        #expect(mockFileOpeningService.openOrCreateContainerArgValues.first?.dataFiles == fileURLs)
    }

    @Test
    func openOrCreateContainer_throwErrorWhenFileOpeningDidNotSucceed() async throws {
        let tempFileURL = URL(fileURLWithPath: "/mock/path/test.txt")
        let tempFileURL2 = URL(fileURLWithPath: "/mock/path/test2.txt")

        let fileURLs = [tempFileURL, tempFileURL2]

        mockFileOpeningService.openOrCreateContainerHandler = { _, _ in
            throw DigiDocError.containerOpeningFailed(
                ErrorDetail(message: "Unable to open container")
            )
        }

        do {
            _ = try await repository.openOrCreateContainer(urls: fileURLs, isSivaConfirmed: true)
            Issue.record("Expected DigiDocError.containerOpeningFailed but no error was thrown")
            return
        } catch let error as DigiDocError {
            if case .containerOpeningFailed = error {
                #expect(true)
            } else {
                Issue.record("Unexpected DigiDocError case: \(error)")
                return
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
            return
        }
    }

    @Test
    func isSivaConfirmationNeeded_returnTrue() async {
        let testFiles = [URL(fileURLWithPath: "/tmp/file1.pdf"), URL(fileURLWithPath: "/tmp/file2.pdf")]
        mockSivaService.isSivaConfirmationNeededHandler = { files in
            #expect(files == testFiles)
            return true
        }

        let isSivaConfirmationNeeded = await repository.isSivaConfirmationNeeded(files: testFiles)

        #expect(isSivaConfirmationNeeded)
        #expect(mockSivaService.isSivaConfirmationNeededCallCount == 1)
        #expect(mockSivaService.isSivaConfirmationNeededArgValues.first == testFiles)
    }

    @Test
    func isSivaConfirmationNeeded_returnFalse() async {
        let testFiles = [URL(fileURLWithPath: "/tmp/file1.pdf"), URL(fileURLWithPath: "/tmp/file2.pdf")]
        mockSivaService.isSivaConfirmationNeededHandler = { _ in false }

        let isSivaConfirmationNeeded = await repository.isSivaConfirmationNeeded(files: testFiles)

        #expect(!isSivaConfirmationNeeded)
        #expect(mockSivaService.isSivaConfirmationNeededCallCount == 1)
        #expect(mockSivaService.isSivaConfirmationNeededArgValues.first == testFiles)
    }
}
