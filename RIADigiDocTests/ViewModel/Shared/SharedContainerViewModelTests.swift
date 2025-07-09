import Foundation
import Testing
import LibdigidocLibSwift
import CommonsLibMocks
import UtilsLibMocks

@MainActor
struct SharedContainerViewModelTests {
    private let mockFileManager: FileManagerProtocolMock
    private let mockContainerUtil: ContainerUtilProtocolMock

    private let viewModel: SharedContainerViewModel!

    init() async throws {
        mockFileManager = FileManagerProtocolMock()
        mockContainerUtil = ContainerUtilProtocolMock()

        viewModel = SharedContainerViewModel()
    }

    @Test
    func setSignedContainer_success() async {
        let signedContainer = SignedContainer(
            fileManager: mockFileManager,
            containerUtil: mockContainerUtil
        )

        viewModel.setSignedContainer(signedContainer: signedContainer)
        let result = viewModel.getSignedContainer()

        let signedContainerName = await signedContainer.getContainerName()
        let containerName = await result?.getContainerName()

        #expect(signedContainerName == containerName)
    }

    @Test
    func setSignedContainer_returnNilWhenSignedContainerNotExist() {
        viewModel.setSignedContainer(signedContainer: nil)
        let result = viewModel.getSignedContainer()

        #expect(result == nil)
    }

    @Test
    func setFileOpeningResult_success() {
        let fileURLs = [
            URL(fileURLWithPath: "/path/to/file1"),
            URL(fileURLWithPath: "/path/to/file2")
        ]
        let fileOpeningResult: Result<[URL], Error> = .success(fileURLs)

        viewModel.setFileOpeningResult(fileOpeningResult: fileOpeningResult)
        let result = viewModel.getFileOpeningResult()

        switch result {
        case .success(let urls):
            #expect(fileURLs == urls)
        case .failure, .none:
            Issue.record("Expected success result")
            return
        }
    }

    @Test
    func setFileOpeningResult_errorSetWhenThrown() {
        let error = NSError(domain: "TestDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        let fileOpeningResult: Result<[URL], Error> = .failure(error)

        viewModel.setFileOpeningResult(fileOpeningResult: fileOpeningResult)
        let result = viewModel.getFileOpeningResult()

        switch result {
        case .failure(let resultError as NSError):
            #expect(error == resultError)
        case .success, .none:
            Issue.record("Expected error to be thrown")
            return
        }
    }

    @Test
    func setFileOpeningResult_returnNilWhenFileOpeningResultNotExist() {
        viewModel.setFileOpeningResult(fileOpeningResult: nil)
        let result = viewModel.getFileOpeningResult()

        #expect(result == nil)
    }
}
