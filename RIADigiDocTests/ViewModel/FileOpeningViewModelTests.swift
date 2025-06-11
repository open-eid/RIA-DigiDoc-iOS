import Foundation
import LibdigidocLibSwift
import CommonsLib
import Testing

@MainActor
struct FileOpeningViewModelTests {
    private var mockFileOpeningRepository: FileOpeningRepositoryProtocolMock!
    private var mockSharedContainerViewModel: SharedContainerViewModelProtocolMock!
    private var viewModel: FileOpeningViewModel!

    init() async throws {
        mockFileOpeningRepository = FileOpeningRepositoryProtocolMock()
        mockSharedContainerViewModel = SharedContainerViewModelProtocolMock()
        viewModel = FileOpeningViewModel(
            fileOpeningRepository: mockFileOpeningRepository,
            sharedContainerViewModel: mockSharedContainerViewModel
        )
    }

    @Test
    func handleFiles_success() async throws {
        let validURLs = [URL(fileURLWithPath: "/path/to/validFile")]
        let signedContainer = SignedContainer()
        let result: Result<[URL], Error> = .success(validURLs)

        mockSharedContainerViewModel.getFileOpeningResultHandler = {
            return result
        }

        mockSharedContainerViewModel.setSignedContainerHandler = { @Sendable _ in }

        mockFileOpeningRepository.getValidFilesHandler = { @Sendable _ in
            return validURLs
        }

        mockFileOpeningRepository.openOrCreateContainerHandler = { @Sendable _ in
            return signedContainer
        }

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

        mockFileOpeningRepository.getValidFilesHandler = { @Sendable _ in
            return []
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
    func handleFiles_throwNoDataFilesErrorWhenGetValidFilesThrowsError() async throws {
        let error = FileOpeningError.noDataFiles
        let result: Result<[URL], Error> = .failure(error)

        mockSharedContainerViewModel.getFileOpeningResultHandler = {
            return result
        }

        mockFileOpeningRepository.getValidFilesHandler = { @Sendable _ in
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

        mockFileOpeningRepository.getValidFilesHandler = { @Sendable _ in
            return []
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
