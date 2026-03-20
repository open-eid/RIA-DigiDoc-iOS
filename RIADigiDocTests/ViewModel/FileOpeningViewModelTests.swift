/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
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
import FactoryKit
import FactoryTesting
import LibdigidocLibSwift
import CommonsLib
import CommonsTestShared
import CommonsLibMocks
import UtilsLibMocks
import LibdigidocLibSwiftMocks

@MainActor
struct FileOpeningViewModelTests {
    private let mockFileOpeningRepository: FileOpeningRepositoryProtocolMock
    private let mockSivaRepository: SivaRepositoryProtocolMock
    private let mockSharedContainerViewModel: SharedContainerViewModelProtocolMock
    private let mockFileOpeningService: FileOpeningServiceProtocolMock
    private let mockFileUtil: FileUtilProtocolMock
    private let mockFileManager: FileManagerProtocolMock
    private let mockContainerUtil: ContainerUtilProtocolMock

    private let viewModel: FileOpeningViewModel

    init() async throws {
        mockFileOpeningRepository = FileOpeningRepositoryProtocolMock()
        mockSivaRepository = SivaRepositoryProtocolMock()
        mockSharedContainerViewModel = SharedContainerViewModelProtocolMock()
        mockFileOpeningService = FileOpeningServiceProtocolMock()
        mockFileUtil = FileUtilProtocolMock()
        mockFileManager = FileManagerProtocolMock()
        mockContainerUtil = ContainerUtilProtocolMock()

        viewModel = FileOpeningViewModel(
            fileOpeningRepository: mockFileOpeningRepository,
            sivaRepository: mockSivaRepository,
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

        mockSharedContainerViewModel.getFileOpeningResultHandler = { result }

        mockSharedContainerViewModel.setSignedContainerHandler = { _ in }

        mockFileOpeningRepository.getValidFilesHandler = { _ in validURLs }

        mockFileOpeningRepository.openOrCreateContainerHandler = { _, _ in signedContainer }

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

        await #expect(throws: Never.self) {
            await viewModel.handleFiles()
        }
    }

    @Test
    func handleFiles_throwNoDataFilesErrorWhenNoFileOpeningResultNil() async throws {
        let expectedError = "Could not load selected files"

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
        let isNavigatingToSigningView = viewModel.isNavigatingToSigningView
        let errorMessage = viewModel.errorMessage?.key

        #expect(!isFileOpeningLoading)
        #expect(!isNavigatingToSigningView)
        #expect(expectedError == errorMessage)
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
        let isNavigatingToSigningView = viewModel.isNavigatingToSigningView
        let errorMessage = viewModel.errorMessage?.key

        #expect(!isFileOpeningLoading)
        #expect(!isNavigatingToSigningView)
        #expect(errorMessage == "Could not load selected files")
    }

    @Test
    func handleFiles_throwNoDataFilesWhenValidFilesEmpty() async throws {
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
        let isNavigatingToSigningView = viewModel.isNavigatingToSigningView
        let errorMessage = viewModel.errorMessage?.key

        #expect(!isFileOpeningLoading)
        #expect(!isNavigatingToSigningView)
        #expect(errorMessage == "Could not load selected files")
    }

    @Test
    func handleSivaConfirmation_successWithNonSivaContainer() async throws {
        let mockContainer = SignedContainerProtocolMock()
        mockContainer.getContainerMimetypeHandler = { Constants.MimeType.Pdf }

        mockFileOpeningRepository.openOrCreateContainerHandler = { _, isSivaConfirmed in
            #expect(isSivaConfirmed)
            return mockContainer
        }

        mockFileOpeningRepository.getValidFilesHandler = { _ in
            [URL(filePath: "/mock/file.txt")]
        }
        mockSharedContainerViewModel.getFileOpeningMethodHandler = { .signing }
        mockSharedContainerViewModel.currentContainerHandler = { mockContainer }

        guard let sharedContainerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: Constants.Identifier.Group
        ) else {
            Issue.record("Expected a valid shared container URL")
            return
        }

        mockFileManager.containerURLHandler = { _ in sharedContainerURL }

        mockFileUtil.removeSharedFilesHandler = { _ in }

        await viewModel.handleFiles()
        await viewModel.handleSivaConfirmation()

        let rawContainerFile = await mockContainer.getRawContainerFile()

        #expect(mockSharedContainerViewModel.setAddedFilesCountCallCount == 1)
        if let count = mockSharedContainerViewModel.setAddedFilesCountArgValues.first {
            #expect(count >= 0)
        }

        #expect(mockSharedContainerViewModel.setSignedContainerCallCount == 1)
        await #expect(
            (mockSharedContainerViewModel.setSignedContainerArgValues.first as? SignedContainer)?
                .getRawContainerFile() == rawContainerFile
        )

        #expect(viewModel.isSivaConfirmed)
        #expect(viewModel.isNavigatingToSigningView)
        #expect(!viewModel.isFileOpeningLoading)
    }

    @Test
    func handleSivaConfirmation_successWithAsicsContainer() async throws {
        let mockMainSignedContainer = SignedContainerProtocolMock()
        let mockNestedSignedContainer = SignedContainerProtocolMock()
        mockMainSignedContainer.getContainerMimetypeHandler = { Constants.MimeType.Asics }

        mockFileOpeningRepository.getValidFilesHandler = { _ in
            [URL(filePath: "/mock/file.txt")]
        }
        mockFileOpeningRepository.openOrCreateContainerHandler = { _, _ in mockMainSignedContainer }
        mockSivaRepository.isTimestampedContainerHandler = { _ in true }
        mockSivaRepository.getTimestampedContainerHandler = { _ in mockNestedSignedContainer }
        mockSharedContainerViewModel.getFileOpeningMethodHandler = { .signing }
        mockSharedContainerViewModel.currentContainerHandler = { mockNestedSignedContainer }

        guard let sharedContainerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: Constants.Identifier.Group
        ) else {
            Issue.record("Expected a valid shared container URL")
            return
        }

        mockFileManager.containerURLHandler = { _ in sharedContainerURL }

        mockFileUtil.removeSharedFilesHandler = { _ in }

        await viewModel.handleFiles()
        await viewModel.handleSivaConfirmation()

        #expect(mockFileOpeningRepository.openOrCreateContainerCallCount == 1)
        #expect(mockSharedContainerViewModel.setSignedContainerCallCount == 1)
        #expect(viewModel.isSivaConfirmed)
        #expect(viewModel.isNavigatingToSigningView)
    }

    @Test
    func handleSivaConfirmation_successWithNonTimestampedAsicsContainer() async throws {
        let mockMainSignedContainer = SignedContainerProtocolMock()
        let mockNestedSignedContainer = SignedContainerProtocolMock()
        mockMainSignedContainer.getContainerMimetypeHandler = { Constants.MimeType.Asics }

        mockFileOpeningRepository.getValidFilesHandler = { _ in
            [URL(filePath: "/mock/file.txt")]
        }
        mockFileOpeningRepository.openOrCreateContainerHandler = { _, _ in mockMainSignedContainer }
        mockSivaRepository.isTimestampedContainerHandler = { _ in false }
        mockSivaRepository.getTimestampedContainerHandler = { _ in mockNestedSignedContainer }
        mockSharedContainerViewModel.getFileOpeningMethodHandler = { .signing }
        mockSharedContainerViewModel.currentContainerHandler = { mockNestedSignedContainer }

        guard let sharedContainerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: Constants.Identifier.Group
        ) else {
            Issue.record("Expected a valid shared container URL")
            return
        }

        mockFileManager.containerURLHandler = { _ in sharedContainerURL }

        mockFileUtil.removeSharedFilesHandler = { _ in }

        await viewModel.handleFiles()
        await viewModel.handleSivaConfirmation()

        #expect(mockFileOpeningRepository.openOrCreateContainerCallCount == 1)
        #expect(mockSharedContainerViewModel.setSignedContainerCallCount == 1)
        #expect(viewModel.isSivaConfirmed)
        #expect(viewModel.isNavigatingToSigningView)
    }

    @Test
    func handleSivaConfirmation_handleErrorWhenContainerCreationFailedErrorThrown() async {
        mockFileOpeningRepository.openOrCreateContainerHandler = { _, _ in
            throw DigiDocError.containerCreationFailed(
                ErrorDetail(message: "Cannot create or open container")
            )
        }

        mockSharedContainerViewModel.getFileOpeningMethodHandler = { .signing }

        await viewModel.handleSivaConfirmation()

        #expect(mockSharedContainerViewModel.setSignedContainerCallCount == 0)
        #expect(!viewModel.isNavigatingToSigningView)
    }

    @Test
    func handleSivaCancellation_handleDdocCancelling() async {
        let mockContainer = try? TestContainerUtil.createMockContainer(
            with: ["mimetype": Constants.MimeType.Ddoc],
            containerExtension: Constants.Extension.Ddoc
        )

        guard let container = mockContainer else {
            Issue.record("Expected a valid container URL")
            return
        }

        mockFileOpeningRepository.getValidFilesHandler = { _ in [container] }
        mockFileUtil.removeSharedFilesHandler = { _ in }
        mockFileManager.containerURLHandler = { _ in URL(fileURLWithPath: "/mock/appGroup/") }
        mockFileManager.fileExistsHandler = { _ in true }

        mockFileUtil.getFileFromZipFileHandler = { _, _ in URL(fileURLWithPath: "mimetype") }

        await viewModel.handleFiles()

        await viewModel.handleSivaCancellation()

        #expect(mockSharedContainerViewModel.setAddedFilesCountCallCount == 1)
        #expect(mockSharedContainerViewModel.setSignedContainerCallCount == 0)
        #expect(!viewModel.isSivaConfirmed)
        #expect(!viewModel.isNavigatingToSigningView)
        #expect(!viewModel.isFileOpeningLoading)
    }

    @Test
    func handleSivaCancellation_successWithAsicsContainer() async throws {
        let mockSignedContainer = SignedContainerProtocolMock()

        let mockContainer = try? TestContainerUtil.createMockContainer(
            with: ["mimetype": Constants.MimeType.Asics],
            containerExtension: Constants.Extension.Asics
        )

        guard let container = mockContainer else {
            Issue.record("Expected a valid container URL")
            return
        }

        mockFileOpeningRepository.getValidFilesHandler = { _ in [container] }
        mockFileUtil.removeSharedFilesHandler = { _ in }
        mockFileManager.containerURLHandler = { _ in URL(fileURLWithPath: "/mock/appGroup/") }
        mockFileManager.fileExistsHandler = { _ in true }

        mockFileUtil.getFileFromZipFileHandler = { _, _ in URL(fileURLWithPath: "mimetype") }

        mockFileOpeningRepository.openOrCreateContainerHandler = { _, confirmed in
            #expect(!confirmed)
            return mockSignedContainer
        }

        mockSharedContainerViewModel.currentContainerHandler = { mockSignedContainer }

        await viewModel.handleFiles()

        await viewModel.handleSivaCancellation()

        let rawContainerFile = await mockSignedContainer.getRawContainerFile()

        #expect(mockSharedContainerViewModel.setSignedContainerCallCount == 1)
        #expect(mockSharedContainerViewModel.setAddedFilesCountCallCount == 1)
        await #expect(
            (mockSharedContainerViewModel.setSignedContainerArgValues.first as? SignedContainer)?
                .getRawContainerFile() == rawContainerFile
        )
        #expect(!viewModel.isSivaConfirmed)
        #expect(viewModel.isNavigatingToSigningView)
        #expect(!viewModel.isFileOpeningLoading)
    }

    @Test
    func handleSivaCancellation_handleErrorWhenAsicsContainerOpeningDidNotSucceed() async {
        let mockContainer = try? TestContainerUtil.createMockContainer(
            with: ["mimetype": Constants.MimeType.Asics],
            containerExtension: Constants.Extension.Asics
        )

        guard let container = mockContainer else {
            Issue.record("Expected a valid container URL")
            return
        }

        mockFileOpeningRepository.getValidFilesHandler = { _ in [container] }
        mockFileUtil.removeSharedFilesHandler = { _ in }
        mockFileManager.containerURLHandler = { _ in URL(fileURLWithPath: "/mock/appGroup/") }
        mockFileManager.fileExistsHandler = { _ in true }

        mockFileUtil.getFileFromZipFileHandler = { _, _ in URL(fileURLWithPath: "mimetype") }

        mockFileOpeningRepository.openOrCreateContainerHandler = { _, _ in
            throw DigiDocError.containerOpeningFailed(
                ErrorDetail(
                    message: "Cannot create or open container."
                )
            )
        }

        await viewModel.handleFiles()

        await viewModel.handleSivaCancellation()

        #expect(mockSharedContainerViewModel.setSignedContainerCallCount == 0)
        #expect(mockSharedContainerViewModel.setAddedFilesCountCallCount == 1)
        #expect(!viewModel.isSivaConfirmed)
        #expect(!viewModel.isNavigatingToSigningView)
        #expect(!viewModel.isFileOpeningLoading)
    }

    @Test
    func handleSivaCancellation_handleErrorWithNonSivaContainer() async {
        let mockContainer = try? TestContainerUtil.createMockContainer(
            with: ["mimetype": Constants.MimeType.Asice],
            containerExtension: Constants.Extension.Asice
        )

        guard let container = mockContainer else {
            Issue.record("Expected a valid container URL")
            return
        }

        mockFileOpeningRepository.getValidFilesHandler = { _ in [container] }
        mockFileUtil.removeSharedFilesHandler = { _ in }
        mockFileManager.containerURLHandler = { _ in URL(fileURLWithPath: "/mock/appGroup/") }
        mockFileManager.fileExistsHandler = { _ in true }

        mockFileUtil.getFileFromZipFileHandler = { _, _ in URL(fileURLWithPath: "mimetype") }

        await viewModel.handleFiles()

        await viewModel.handleSivaCancellation()

        #expect(mockSharedContainerViewModel.setSignedContainerCallCount == 0)
        #expect(mockSharedContainerViewModel.setAddedFilesCountCallCount == 1)
        #expect(!viewModel.isSivaConfirmed)
        #expect(!viewModel.isNavigatingToSigningView)
        #expect(!viewModel.isFileOpeningLoading)
    }

    @Test
    func handleSivaCancellation_handleErrorWhenNoFileAndMimetype() async {
        mockFileUtil.getFileFromZipFileHandler = { _, _ in URL(fileURLWithPath: "mimetype") }

        await viewModel.handleSivaCancellation()

        #expect(mockSharedContainerViewModel.setSignedContainerCallCount == 0)
        #expect(mockSharedContainerViewModel.setAddedFilesCountCallCount == 1)
        #expect(!viewModel.isSivaConfirmed)
        #expect(!viewModel.isNavigatingToSigningView)
        #expect(!viewModel.isFileOpeningLoading)
    }

    @Test
    func showFileAddedMessage_returnFalseIfNoContainer() async {
        mockSharedContainerViewModel.currentContainerHandler = { nil }

        let showFileAddedMessage = await viewModel.showFileAddedMessage()

        #expect(!showFileAddedMessage)
        #expect(mockSharedContainerViewModel.currentContainerCallCount == 1)
    }

    @Test
    func showFileAddedMessage_returnFalseWhenContainerIsSigned() async {
        let mockContainer = SignedContainerProtocolMock()
        mockContainer.getSignaturesHandler = {[
            MockSignatureWrapper.mockSignatureWrapper(signatureId: "1"),
            MockSignatureWrapper.mockSignatureWrapper(signatureId: "2")
        ]}

        mockSharedContainerViewModel.currentContainerHandler = { mockContainer }
        mockContainer.isExistingContainerHandler = { true }

        let showFileAddedMessage = await viewModel.showFileAddedMessage()

        #expect(!showFileAddedMessage)
        #expect(mockSharedContainerViewModel.currentContainerCallCount == 1)
    }

    @Test
    func showFileAddedMessage_returnTrueWhenContainerIsNotSigned() async {
        let mockContainer = SignedContainerProtocolMock()
        mockContainer.getSignaturesHandler = { [] }
        mockSharedContainerViewModel.currentContainerHandler = { mockContainer }
        mockContainer.isExistingContainerHandler = { false }

        let showFileAddedMessage = await viewModel.showFileAddedMessage()

        #expect(showFileAddedMessage)
        #expect(mockSharedContainerViewModel.currentContainerCallCount == 1)
    }

    @Test
    func addedFilesCount_successWhenFilesAreAddedToContainer() {
        mockSharedContainerViewModel.getAddedFilesCountHandler = { 5 }

        let addedFilesCount = viewModel.addedFilesCount()

        #expect(addedFilesCount == 5)
        #expect(mockSharedContainerViewModel.getAddedFilesCountCallCount == 1)
    }

    @Test
    func handleError_success() {
        viewModel.handleError()

        #expect(viewModel.errorMessage == nil)
        #expect(!viewModel.isFileOpeningLoading)
        #expect(!viewModel.isNavigatingToSigningView)
    }

    @Test
    func isSivaConfirmationNeeded_returnsTrue() async {
        mockFileOpeningRepository.isSivaConfirmationNeededHandler = { _ in true }

        let isSivaConfirmationNeeded = await viewModel.isSivaConfirmationNeeded()

        #expect(isSivaConfirmationNeeded)
        #expect(mockFileOpeningRepository.isSivaConfirmationNeededCallCount == 1)
    }

    @Test
    func isSivaConfirmationNeeded_returnsFalse() async {
        mockFileOpeningRepository.isSivaConfirmationNeededHandler = { _ in false }

        let isSivaConfirmationNeeded = await viewModel.isSivaConfirmationNeeded()

        #expect(!isSivaConfirmationNeeded)
        #expect(mockFileOpeningRepository.isSivaConfirmationNeededCallCount == 1)
    }
}
