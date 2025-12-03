/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

import Foundation
import Testing
import CommonsLib
import CommonsLibMocks
import UtilsLib
import UtilsLibMocks

@MainActor
struct HomeViewModelTests {
    private let mockSharedContainerViewModel: SharedContainerViewModelProtocolMock
    private let mockFileManager: FileManagerProtocolMock
    private let mockFileUtil: FileUtilProtocolMock
    private let viewModel: HomeViewModel

    init() async throws {
        mockSharedContainerViewModel = SharedContainerViewModelProtocolMock()
        mockFileManager = FileManagerProtocolMock()
        mockFileUtil = FileUtilProtocolMock()
        viewModel = HomeViewModel(
            sharedContainerViewModel: mockSharedContainerViewModel,
            fileManager: mockFileManager,
            fileUtil: mockFileUtil
        )
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

        mockSharedContainerViewModel.setFileOpeningResultHandler = { _ in }

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

        mockSharedContainerViewModel.setFileOpeningResultHandler = { _ in }

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
