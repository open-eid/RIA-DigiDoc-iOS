import Foundation
import Testing
import Cuckoo

final class MainSignatureViewModelTests {
    private var mockSharedContainerViewModel: MockSharedContainerViewModel!
    private var viewModel: MainSignatureViewModel!

    init() async throws {
        mockSharedContainerViewModel = MockSharedContainerViewModel()
        viewModel = await MainSignatureViewModel(sharedContainerViewModel: mockSharedContainerViewModel)
    }

    deinit {
        viewModel = nil
        mockSharedContainerViewModel = nil
    }

    @Test
    func didUserCancelFileOpening_returnTrueWhenNotImportingAndNotLoading() async {
        let isImportingValue = false
        let isFileOpeningLoading = false

        let result = await viewModel.didUserCancelFileOpening(
            isImportingValue: isImportingValue,
            isFileOpeningLoading: isFileOpeningLoading
        )

        #expect(result)
    }

    @Test
    func didUserCancelFileOpening_returnFalseWhenImportingAndLoading() async {
        let isImportingValue = true
        let isFileOpeningLoading = true

        let result = await viewModel.didUserCancelFileOpening(
            isImportingValue: isImportingValue,
            isFileOpeningLoading: isFileOpeningLoading
        )

        #expect(!result)
    }

    @Test
    func didUserCancelFileOpening_returnFalseWhenNotImportingButLoading() async {
        let isImportingValue = false
        let isFileOpeningLoading = true

        let result = await viewModel.didUserCancelFileOpening(
            isImportingValue: isImportingValue,
            isFileOpeningLoading: isFileOpeningLoading
        )

        #expect(!result)
    }

    @Test
    func didUserCancelFileOpening_returnFalseWhenImportingButNotLoading() async {
        let isImportingValue = true
        let isFileOpeningLoading = false

        let result = await viewModel.didUserCancelFileOpening(
            isImportingValue: isImportingValue,
            isFileOpeningLoading: isFileOpeningLoading
        )

        #expect(!result)
    }

    @Test
    func setChosenFiles_success() async {
        let chosenFiles: Result<[URL], Error> = .success([URL(fileURLWithPath: "/path/to/file")])

        stub(mockSharedContainerViewModel) { stub in
            when(stub.setFileOpeningResult(fileOpeningResult: any())).thenDoNothing()
        }

        await viewModel.setChosenFiles(chosenFiles)

        verify(mockSharedContainerViewModel).setFileOpeningResult(fileOpeningResult: any())
    }

    @Test
    func setChosenFiles_successWithError() async {
        let chosenFiles: Result<[URL], Error> = .failure(FileOpeningError.noDataFiles)

        stub(mockSharedContainerViewModel) { stub in
            when(stub.setFileOpeningResult(fileOpeningResult: any())).thenDoNothing()
        }

        await viewModel.setChosenFiles(chosenFiles)

        verify(mockSharedContainerViewModel).setFileOpeningResult(fileOpeningResult: any())
    }
}
