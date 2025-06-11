import Foundation
import Testing
import CommonsLib

@MainActor
struct MainSignatureViewModelTests {
    private var mockSharedContainerViewModel: SharedContainerViewModelProtocolMock!
    private var viewModel: MainSignatureViewModel!

    init() async throws {
        mockSharedContainerViewModel = SharedContainerViewModelProtocolMock()
        viewModel = MainSignatureViewModel(sharedContainerViewModel: mockSharedContainerViewModel)
    }

    @Test
    func didUserCancelFileOpening_returnTrueWhenNotImportingAndNotLoading() async {
        let isImportingValue = false
        let isFileOpeningLoading = false

        let result = viewModel.didUserCancelFileOpening(
            isImportingValue: isImportingValue,
            isFileOpeningLoading: isFileOpeningLoading
        )

        #expect(result)
    }

    @Test
    func didUserCancelFileOpening_returnFalseWhenImportingAndLoading() async {
        let isImportingValue = true
        let isFileOpeningLoading = true

        let result = viewModel.didUserCancelFileOpening(
            isImportingValue: isImportingValue,
            isFileOpeningLoading: isFileOpeningLoading
        )

        #expect(!result)
    }

    @Test
    func didUserCancelFileOpening_returnFalseWhenNotImportingButLoading() async {
        let isImportingValue = false
        let isFileOpeningLoading = true

        let result = viewModel.didUserCancelFileOpening(
            isImportingValue: isImportingValue,
            isFileOpeningLoading: isFileOpeningLoading
        )

        #expect(!result)
    }

    @Test
    func didUserCancelFileOpening_returnFalseWhenImportingButNotLoading() async {
        let isImportingValue = true
        let isFileOpeningLoading = false

        let result = viewModel.didUserCancelFileOpening(
            isImportingValue: isImportingValue,
            isFileOpeningLoading: isFileOpeningLoading
        )

        #expect(!result)
    }

    @Test
    func setChosenFiles_success() async {
        let chosenFiles: Result<[URL], Error> = .success([URL(fileURLWithPath: "/path/to/file")])

        mockSharedContainerViewModel.setFileOpeningResultHandler = { @Sendable _ in }

        viewModel.setChosenFiles(chosenFiles)

        #expect(mockSharedContainerViewModel.setFileOpeningResultCallCount == 1)

        guard case let .success(fileOpeningResultUrls) =
                mockSharedContainerViewModel.setFileOpeningResultArgValues.first,
              case let .success(expectedUrls) = chosenFiles,
              fileOpeningResultUrls == expectedUrls else {
            Issue.record("Expected to have chosen files set")
            return
        }
    }

    @Test
    func setChosenFiles_successWithError() async {
        let chosenFiles: Result<[URL], Error> = .failure(FileOpeningError.noDataFiles)

        mockSharedContainerViewModel.setFileOpeningResultHandler = { @Sendable _ in }

        viewModel.setChosenFiles(chosenFiles)

        #expect(mockSharedContainerViewModel.setFileOpeningResultCallCount == 1)

        guard
            case let .failure(actualError) = mockSharedContainerViewModel.setFileOpeningResultArgValues.first,
            case let .failure(expectedError) = chosenFiles,
            let actualFileOpeningError = actualError as? FileOpeningError,
            let expectedFileOpeningError = expectedError as? FileOpeningError,
            actualFileOpeningError == expectedFileOpeningError
        else {
            Issue.record("Expected to have matching failure errors")
            return
        }
    }
}
