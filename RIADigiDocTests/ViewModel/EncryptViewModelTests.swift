// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import CommonsLib
import CommonsLibMocks
import CryptoSwift
import Foundation
import LibdigidocLibSwiftMocks
import Testing
import UtilsLibMocks

@MainActor
struct EncryptViewModelTests {

    private let viewModel: EncryptViewModel
    private let mockSharedContainerViewModel = SharedContainerViewModelProtocolMock()

    init() {
        viewModel = EncryptViewModel(
            sharedContainerViewModel: mockSharedContainerViewModel,
            fileOpeningService: FileOpeningServiceProtocolMock(),
            mimeTypeCache: MimeTypeCacheProtocolMock(),
            mimeTypeDecoder: MimeTypeDecoderProtocolMock(),
            fileUtil: FileUtilProtocolMock(),
            fileManager: FileManagerProtocolMock(),
            fileInspector: FileInspectorProtocolMock(),
            sivaRepository: SivaRepositoryProtocolMock()
        )
    }

    private func stubContainer() -> CryptoContainerProtocolMock {
        let container = CryptoContainerProtocolMock()
        container.getRawContainerFileHandler = { URL(filePath: "/mock/path/to/container.cdoc2") }
        container.getContainerNameHandler = { "container.cdoc2" }
        container.getDataFilesHandler = { [URL(filePath: "/mock/path/to/text.txt")] }
        container.getRecipientsHandler = { [] }
        container.getContainerMimetypeHandler = { CommonsLib.Constants.MimeType.Cdoc }
        mockSharedContainerViewModel.currentContainerHandler = { container }
        return container
    }

    @Test
    func encryptContainer_reportsSuccessOnlyWhenEncryptionSucceeds() async {
        _ = stubContainer()
        let encrypted = CryptoContainerProtocolMock()
        encrypted.getRawContainerFileHandler = { URL(filePath: "/mock/path/to/container.cdoc2") }
        encrypted.getContainerNameHandler = { "container.cdoc2" }
        encrypted.getDataFilesHandler = { [] }
        encrypted.getRecipientsHandler = { [] }
        encrypted.getContainerMimetypeHandler = { CommonsLib.Constants.MimeType.Cdoc }
        viewModel.encryptAction = { _, _, _ in encrypted }

        await viewModel.encryptContainer()

        #expect(viewModel.successMessage == ToastMessage(key: "Container successfully encrypted", args: []))
        #expect(viewModel.errorMessage == nil)
        #expect(mockSharedContainerViewModel.setCryptoContainerCallCount == 1)
    }

    @Test
    func encryptContainer_reportsOnlyTheErrorWhenEncryptionFails() async {
        _ = stubContainer()
        viewModel.encryptAction = { _, _, _ in
            throw CryptoError.containerCreationFailed(
                CryptoErrorDetail(message: "Cannot create an empty crypto container")
            )
        }

        await viewModel.encryptContainer()

        #expect(viewModel.errorMessage == ToastMessage(key: "Cannot create an empty crypto container", args: []))
        #expect(viewModel.successMessage == nil)
        #expect(mockSharedContainerViewModel.setCryptoContainerCallCount == 0)
    }

    @Test
    func encryptContainer_reportsAnErrorWhenThereIsNoContainer() async {
        mockSharedContainerViewModel.currentContainerHandler = { nil }

        await viewModel.encryptContainer()

        #expect(viewModel.errorMessage == ToastMessage(key: "Encrypt general error", args: []))
        #expect(viewModel.successMessage == nil)
    }

    @Test
    func encryptContainer_usesTranslatableKeyForNativeError() async {
        _ = stubContainer()
        viewModel.encryptAction = { _, _, _ in
            throw NSError(
                domain: "ee.ria.digidoc.CryptoLib",
                code: 1000,
                userInfo: [NSLocalizedDescriptionKey: "Failed to start encryption"]
            )
        }

        await viewModel.encryptContainer()

        #expect(viewModel.errorMessage == ToastMessage(key: "Encrypt general error", args: []))
        #expect(viewModel.successMessage == nil)
    }

    @Test
    func encryptContainer_usesGeneralKeyForOtherCryptoErrors() async {
        _ = stubContainer()
        viewModel.encryptAction = { _, _, _ in throw CryptoError.wrongDecryptionKey }

        await viewModel.encryptContainer()

        #expect(viewModel.errorMessage == ToastMessage(key: "Encrypt general error", args: []))
    }
}
