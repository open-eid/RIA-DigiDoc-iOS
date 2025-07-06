import Foundation
import Testing
import FactoryKit
import FactoryTesting
import LibdigidocLibSwift
import CommonsLib
import CommonsLibMocks
import UtilsLibMocks

@MainActor
struct FileOpeningViewModelTests {
    private var mockFileOpeningRepository: FileOpeningRepositoryProtocolMock
    private var mockSharedContainerViewModel: SharedContainerViewModelProtocolMock
    private var mockFileOpeningService: FileOpeningServiceProtocolMock
    private var mockFileUtil: FileUtilProtocolMock
    private var mockFileManager: FileManagerProtocolMock
    private let mockContainerUtil: ContainerUtilProtocolMock

    private var viewModel: FileOpeningViewModel

    init() async throws {
        mockFileOpeningRepository = FileOpeningRepositoryProtocolMock()
        mockSharedContainerViewModel = SharedContainerViewModelProtocolMock()
        mockFileOpeningService = FileOpeningServiceProtocolMock()
        mockFileUtil = FileUtilProtocolMock()
        mockFileManager = FileManagerProtocolMock()
        mockContainerUtil = ContainerUtilProtocolMock()

        viewModel = FileOpeningViewModel(
            fileOpeningRepository: mockFileOpeningRepository,
            sharedContainerViewModel: mockSharedContainerViewModel,
            fileUtil: mockFileUtil,
            fileManager: mockFileManager
        )
    }

    @Test
    func handleFiles_success() async throws {
        let validURLs = [URL(fileURLWithPath: "/path/to/validFile")]
        let signedContainer = SignedContainer(
            fileManager: mockFileManager,
            containerUtil: mockContainerUtil
        )
        let result: Result<[URL], Error> = .success(validURLs)

        mockSharedContainerViewModel.getFileOpeningResultHandler = {
            print("getFileOpeningResultHandler called")
            return result
        }

        mockSharedContainerViewModel.setSignedContainerHandler = { _ in }

        mockFileOpeningRepository.getValidFilesHandler = { _ in validURLs }

        mockFileOpeningRepository.openOrCreateContainerHandler = { _ in signedContainer }

        mockFileOpeningService.getValidFilesHandler = { _ in validURLs }

        mockFileUtil.removeSharedFilesHandler = { _ in }

        guard let sharedContainerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: Constants.Identifier.Group
        ) else {
            Issue.record("Expected a valid shared container URL")
            return
        }

        mockFileManager.containerURLHandler = { _ in sharedContainerURL }
        mockFileManager.fileExistsHandler = { _ in true }

        await viewModel.handleFiles()

        let isFileOpeningLoading = viewModel.isFileOpeningLoading
        let isNavigatingToNextView = viewModel.isNavigatingToNextView

        #expect(!isFileOpeningLoading)
        #expect(isNavigatingToNextView)
        #expect(mockSharedContainerViewModel.setSignedContainerCallCount == 1)

        let receivedSetContainer = mockSharedContainerViewModel.setSignedContainerArgValues.first

        guard let receivedContainer = receivedSetContainer else { return }

        let receivedRawContainerFile = await receivedContainer?.getRawContainerFile()
        let signedContaninerRaw = await signedContainer.getRawContainerFile()

        #expect(receivedRawContainerFile == signedContaninerRaw)
    }

    @Test
    func handleFiles_throwNoDataFilesErrorWhenNoFileOpeningResultNil() async throws {
        let error = FileOpeningError.noDataFiles

        mockSharedContainerViewModel.getFileOpeningResultHandler = {
            return nil
        }

        mockFileOpeningRepository.getValidFilesHandler = { _ in
            return []
        }

        guard let sharedContainerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: Constants.Identifier.Group
        ) else {
            Issue.record("Expected a valid shared container URL")
            return
        }

        mockFileManager.containerURLHandler = { _ in sharedContainerURL }
        mockFileManager.fileExistsHandler = { _ in true }

        await viewModel.handleFiles()

        let isFileOpeningLoading = viewModel.isFileOpeningLoading
        let isNavigatingToNextView = viewModel.isNavigatingToNextView
        let errorMessage = viewModel.errorMessage?.message

        #expect(!isFileOpeningLoading)
        #expect(!isNavigatingToNextView)
        #expect(error.localizedDescription == errorMessage)
    }

    @Test
    func handleFiles_throwNoDataFilesErrorWhenGetValidFilesThrowsError() async throws {
        let error = FileOpeningError.noDataFiles
        let result: Result<[URL], Error> = .failure(error)

        mockSharedContainerViewModel.getFileOpeningResultHandler = {
            return result
        }

        mockFileOpeningRepository.getValidFilesHandler = { _ in
            throw error
        }

        await viewModel.handleFiles()

        let isFileOpeningLoading = viewModel.isFileOpeningLoading
        let isNavigatingToNextView = viewModel.isNavigatingToNextView
        let errorMessage = viewModel.errorMessage?.message

        #expect(!isFileOpeningLoading)
        #expect(!isNavigatingToNextView)
        #expect(error.localizedDescription == errorMessage)
    }

    @Test
    func handleFiles_throwNoDataFilesWhenValidFilesEmpty() async throws {
        let error = FileOpeningError.noDataFiles
        let result: Result<[URL], Error> = .success([])

        mockSharedContainerViewModel.getFileOpeningResultHandler = {
            return result
        }

        mockFileOpeningRepository.getValidFilesHandler = { _ in
            return []
        }

        guard let sharedContainerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: Constants.Identifier.Group
        ) else {
            Issue.record("Expected a valid shared container URL")
            return
        }

        mockFileManager.containerURLHandler = { _ in sharedContainerURL }
        mockFileManager.fileExistsHandler = { _ in true }

        await viewModel.handleFiles()

        let isFileOpeningLoading = viewModel.isFileOpeningLoading
        let isNavigatingToNextView = viewModel.isNavigatingToNextView
        let errorMessage = viewModel.errorMessage?.message

        #expect(!isFileOpeningLoading)
        #expect(!isNavigatingToNextView)
        #expect(error.localizedDescription == errorMessage)
    }

    @Test
    func handleLoading_success() async {
        viewModel.handleLoadingSuccess()

        let isFileOpeningLoading = viewModel.isFileOpeningLoading
        let isNavigatingToNextView = viewModel.isNavigatingToNextView

        #expect(!isFileOpeningLoading)
        #expect(isNavigatingToNextView)
    }

    @Test
    func handleError_success() async {
        viewModel.handleError()

        let errorMessage = viewModel.errorMessage

        let isFileOpeningLoading = viewModel.isFileOpeningLoading
        let isNavigatingToNextView = viewModel.isNavigatingToNextView

        #expect(errorMessage == nil)
        #expect(!isFileOpeningLoading)
        #expect(!isNavigatingToNextView)
    }
}
