import Foundation
import LibdigidocLibSwift
import Testing
import Cuckoo
import CommonsTestShared

final class FileOpeningRepositoryTests {
    private var mockFileOpeningService: MockFileOpeningServiceProtocol!
    private var repository: FileOpeningRepositoryProtocol!

    init() async throws {
        mockFileOpeningService = MockFileOpeningServiceProtocol()
        repository = FileOpeningRepository(fileOpeningService: mockFileOpeningService)
    }

    deinit {
        repository = nil
        mockFileOpeningService = nil
    }

    @Test
    func isFileSizeValid_success() async throws {
        let tempFileURL = TestFileUtil.createSampleFile()

        stub(mockFileOpeningService) { stub in
            when(stub.isFileSizeValid(url: any())).thenReturn(true)
        }

        let isValid = try await repository.isFileSizeValid(url: tempFileURL)

        defer {
            try? FileManager.default.removeItem(at: tempFileURL)
        }

        #expect(isValid)
        verify(mockFileOpeningService).isFileSizeValid(url: equal(to: tempFileURL))
    }

    @Test
    func getValidFiles_success() async throws {
        let tempFileURL = TestFileUtil.createSampleFile()

        let tempFileURL2 = TestFileUtil.createSampleFile()

        let fileURLs = [
            tempFileURL,
            tempFileURL2
        ]

        let result: Result<[URL], any Error> = .success(fileURLs)

        stub(mockFileOpeningService) { stub in
            when(stub.getValidFiles(any())).thenReturn(fileURLs)
        }

        let validFiles = try await repository.getValidFiles(result)

        #expect(fileURLs == validFiles)
        verify(mockFileOpeningService).getValidFiles(any())
    }

    @Test
    func openOrCreateContainer_success() async throws {
        let tempFileURL = TestFileUtil.createSampleFile()

        let tempFileURL2 = TestFileUtil.createSampleFile()

        let fileURLs = [
            tempFileURL,
            tempFileURL2
        ]

        let signedContainer = SignedContainer()

        stub(mockFileOpeningService) { stub in
            when(stub.openOrCreateContainer(dataFiles: any())).thenReturn(signedContainer)
        }

        let result = try await repository.openOrCreateContainer(urls: fileURLs)

        let signedContainerName = await signedContainer.getContainerName()
        let resultContainerName = await result.getContainerName()

        #expect(signedContainerName == resultContainerName)
        verify(mockFileOpeningService).openOrCreateContainer(dataFiles: equal(to: fileURLs))
    }
}
