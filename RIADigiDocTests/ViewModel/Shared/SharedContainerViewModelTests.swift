import Foundation
import Testing
import LibdigidocLibSwift
import CommonsLibMocks
import UtilsLibMocks
import LibdigidocLibSwiftMocks

@MainActor
struct SharedContainerViewModelTests {
    private let mockFileManager: FileManagerProtocolMock
    private let mockContainerUtil: ContainerUtilProtocolMock

    private let viewModel: SharedContainerViewModel

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

        viewModel.setSignedContainer(signedContainer)
        let result = viewModel.currentContainer()

        let signedContainerName = await signedContainer.getContainerName()
        let containerName = await result?.getContainerName()

        #expect(signedContainerName == containerName)
    }

    @Test
    func setSignedContainer_returnNilWhenSignedContainerNotExist() {
        viewModel.setSignedContainer(nil)
        let result = viewModel.currentContainer()

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

    @Test
    func removeLastContainer_returnNilWhenNoContainersToRemove() throws {
        #expect(viewModel.removeLastContainer() == nil)
    }

    @Test
    func setSignedContainer_successWithNotAddingDuplicateContainers() {
        let mockSignedContainer = SignedContainerProtocolMock()
        viewModel.setSignedContainer(mockSignedContainer)
        viewModel.setSignedContainer(mockSignedContainer)

        #expect(viewModel.containers().count == 1)
    }

    @Test
    func removeLastContainer_successReturningLastContainer() {
        let firstMockSignedContainer = SignedContainerProtocolMock()
        let secondMockSignedContainer = SignedContainerProtocolMock()

        viewModel.setSignedContainer(firstMockSignedContainer)
        viewModel.setSignedContainer(secondMockSignedContainer)

        let removed = viewModel.removeLastContainer()

        #expect(removed === secondMockSignedContainer)
        #expect(viewModel.currentContainer() === firstMockSignedContainer)
        #expect(viewModel.containers().count == 1)
    }

    @Test
    func clearContainers_successClearingContainers() {
        let firstMockSignedContainer = SignedContainerProtocolMock()
        let secondMockSignedContainer = SignedContainerProtocolMock()

        viewModel.setSignedContainer(firstMockSignedContainer)
        viewModel.setSignedContainer(secondMockSignedContainer)

        viewModel.clearContainers()

        #expect(viewModel.containers().isEmpty)
        #expect(viewModel.currentContainer() == nil)
    }

    @Test
    func isNestedContainer_returnFalseWhenNoContainerSpecified() {
        #expect(viewModel.isNestedContainer(nil) == false)
    }

    @Test
    func isNestedContainer_returnFalseWhenOnlySingleContainerSpecified() {
        let mockSignedContainer = SignedContainerProtocolMock()

        viewModel.setSignedContainer(mockSignedContainer)
        #expect(viewModel.isNestedContainer(mockSignedContainer) == false)
    }

    @Test
    func isNestedContainer_returnTrueWhenNestedContainerChecked() {
        let firstMockSignedContainer = SignedContainerProtocolMock()
        let secondMockSignedContainer = SignedContainerProtocolMock()

        viewModel.setSignedContainer(firstMockSignedContainer)
        viewModel.setSignedContainer(secondMockSignedContainer)

        #expect(viewModel.isNestedContainer(secondMockSignedContainer) == true)
    }

    @Test
    func isNestedContainer_returnFalseWhenMainContainerChecked() {
        let firstMockSignedContainer = SignedContainerProtocolMock()
        let secondMockSignedContainer = SignedContainerProtocolMock()

        viewModel.setSignedContainer(firstMockSignedContainer)
        viewModel.setSignedContainer(secondMockSignedContainer)

        #expect(viewModel.isNestedContainer(firstMockSignedContainer) == false)
    }

    @Test
    func containers_successReturningAllContainers() {
        let firstMockSignedContainer = SignedContainerProtocolMock()
        let secondMockSignedContainer = SignedContainerProtocolMock()

        viewModel.setSignedContainer(firstMockSignedContainer)
        viewModel.setSignedContainer(secondMockSignedContainer)

        let list = viewModel.containers()
        #expect(list.count == 2)
        #expect(list[0] === firstMockSignedContainer)
        #expect(list[1] === secondMockSignedContainer)
    }
}
