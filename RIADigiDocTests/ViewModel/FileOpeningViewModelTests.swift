import Foundation
import LibdigidocLibSwift
import Testing
import Cuckoo

final class FileOpeningViewModelTests {
    private var mockFileOpeningRepository: MockFileOpeningRepositoryProtocol!
    private var mockSharedContainerViewModel: MockSharedContainerViewModel!
    private var viewModel: FileOpeningViewModel!

    init() async throws {
        mockFileOpeningRepository = MockFileOpeningRepositoryProtocol()
        mockSharedContainerViewModel = MockSharedContainerViewModel()
        viewModel = await FileOpeningViewModel(
            fileOpeningRepository: mockFileOpeningRepository,
            sharedContainerViewModel: mockSharedContainerViewModel
        )
    }

    deinit {
        viewModel = nil
        mockSharedContainerViewModel = nil
        mockFileOpeningRepository = nil
    }

    @Test
    func handleFiles_success() async throws {
        let validURLs = [URL(fileURLWithPath: "/path/to/validFile")]
        let signedContainer = SignedContainer()
        let result: Result<[URL], Error> = .success(validURLs)

        stub(mockSharedContainerViewModel) { stub in
            when(stub.getFileOpeningResult()).thenReturn(result)
            when(stub.setSignedContainer(signedContainer: any())).thenDoNothing()
        }
        stub(mockFileOpeningRepository) { stub in
            when(stub.getValidFiles(any())).thenReturn(validURLs)
            when(stub.openOrCreateContainer(urls: any())).thenReturn(signedContainer)
        }

        await viewModel.handleFiles()

        let isFileOpeningLoading = await viewModel.isFileOpeningLoading
        let isNavigatingToNextView = await viewModel.isNavigatingToNextView

        #expect(!isFileOpeningLoading)
        #expect(isNavigatingToNextView)
        verify(mockSharedContainerViewModel).setSignedContainer(signedContainer: equal(to: signedContainer))
    }

    @Test
    func handleFiles_throwNoDataFilesErrorWhenNoFileOpeningResultNil() async throws {
        let error = FileOpeningError.noDataFiles

        stub(mockSharedContainerViewModel) { stub in
            when(stub.getFileOpeningResult()).thenReturn(nil)
        }

        stub(mockFileOpeningRepository) { stub in
            when(stub.getValidFiles(any())).thenReturn([])
        }

        await viewModel.handleFiles()

        let isFileOpeningLoading = await viewModel.isFileOpeningLoading
        let isNavigatingToNextView = await viewModel.isNavigatingToNextView
        let errorMessage = await viewModel.errorMessage?.message

        #expect(!isFileOpeningLoading)
        #expect(!isNavigatingToNextView)
        #expect(error.localizedDescription == errorMessage)
    }

    @Test
    func handleFiles_throwNoDataFilesErrorWhenGetValidFilesThrowsError() async throws {
        let error = FileOpeningError.noDataFiles
        let result: Result<[URL], Error> = .failure(error)

        stub(mockSharedContainerViewModel) { stub in
            when(stub.getFileOpeningResult()).thenReturn(result)
        }

        stub(mockFileOpeningRepository) { stub in
            when(stub.getValidFiles(any())).thenThrow(error)
        }

        await viewModel.handleFiles()

        let isFileOpeningLoading = await viewModel.isFileOpeningLoading
        let isNavigatingToNextView = await viewModel.isNavigatingToNextView
        let errorMessage = await viewModel.errorMessage?.message

        #expect(!isFileOpeningLoading)
        #expect(!isNavigatingToNextView)
        #expect(error.localizedDescription == errorMessage)
    }

    @Test
    func handleFiles_throwNoDataFilesWhenValidFilesEmpty() async throws {
        let error = FileOpeningError.noDataFiles
        let result: Result<[URL], Error> = .success([])

        stub(mockSharedContainerViewModel) { stub in
            when(stub.getFileOpeningResult()).thenReturn(result)
        }

        stub(mockFileOpeningRepository) { stub in
            when(stub.getValidFiles(any())).thenReturn([])
        }

        await viewModel.handleFiles()

        let isFileOpeningLoading = await viewModel.isFileOpeningLoading
        let isNavigatingToNextView = await viewModel.isNavigatingToNextView
        let errorMessage = await viewModel.errorMessage?.message

        #expect(!isFileOpeningLoading)
        #expect(!isNavigatingToNextView)
        #expect(error.localizedDescription == errorMessage)
    }

    @Test
    func handleLoading_success() async {
        await viewModel.handleLoadingSuccess()

        let isFileOpeningLoading = await viewModel.isFileOpeningLoading
        let isNavigatingToNextView = await viewModel.isNavigatingToNextView

        #expect(!isFileOpeningLoading)
        #expect(isNavigatingToNextView)
    }

    @Test
    func handleError_success() async {
        await viewModel.handleError()

        let errorMessage = await viewModel.errorMessage

        let isFileOpeningLoading = await viewModel.isFileOpeningLoading
        let isNavigatingToNextView = await viewModel.isNavigatingToNextView

        #expect(errorMessage == nil)
        #expect(!isFileOpeningLoading)
        #expect(!isNavigatingToNextView)
    }
}
