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

    private func stubContainer(named containerName: String = "container.cdoc2") -> CryptoContainerProtocolMock {
        let container = CryptoContainerProtocolMock()
        container.getRawContainerFileHandler = { URL(filePath: "/mock/path/to/\(containerName)") }
        container.getContainerNameHandler = { containerName }
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

    @Test
    func isCDOC2Container_isTrueForACdoc2Extension() async {
        let container = stubContainer(named: "container.cdoc2")

        #expect(await viewModel.isCDOC2Container(cryptoContainer: container) == true)
    }

    @Test
    func isCDOC2Container_isFalseForACdocExtension() async {
        let container = stubContainer(named: "container.cdoc")

        #expect(await viewModel.isCDOC2Container(cryptoContainer: container) == false)
    }

    @Test
    func isCDOC2Container_isFalseWhenThereIsNoContainer() async {
        #expect(await viewModel.isCDOC2Container(cryptoContainer: nil) == false)
    }

    @Test
    func isCDOC2Container_isTrueForAnUppercaseCdoc2Extension() async {
        let container = stubContainer(named: "container.CDOC2")

        #expect(await viewModel.isCDOC2Container(cryptoContainer: container) == true)
    }

    @Test
    func isCDOC1Container_isTrueForACdocExtension() async {
        let container = stubContainer(named: "container.cdoc")

        #expect(await viewModel.isCDOC1Container(cryptoContainer: container) == true)
    }

    @Test
    func isCDOC1Container_isTrueForAnUppercaseCdocExtension() async {
        let container = stubContainer(named: "container.CDOC")

        #expect(await viewModel.isCDOC1Container(cryptoContainer: container) == true)
    }

    @Test
    func isCDOC1Container_isFalseForACdoc2Extension() async {
        let container = stubContainer(named: "container.cdoc2")

        #expect(await viewModel.isCDOC1Container(cryptoContainer: container) == false)
    }

    @Test
    func isCDOC1Container_isFalseWhenThereIsNoContainer() async {
        #expect(await viewModel.isCDOC1Container(cryptoContainer: nil) == false)
    }

    @Test
    func updateAsyncProperties_recomputesIsContainerCDOC2WhenTheContainerChanges() async {
        await viewModel.loadContainerData(cryptoContainer: stubContainer(named: "container.cdoc2"))
        await viewModel.updateAsyncProperties()

        #expect(viewModel.isContainerCDOC2 == true)

        await viewModel.loadContainerData(cryptoContainer: stubContainer(named: "container.cdoc"))
        await viewModel.updateAsyncProperties()

        #expect(viewModel.isContainerCDOC2 == false)
    }

    @Test
    func isDecryptionUnavailable_isFalseWhenAnEncryptedContainerCanStillBeDecrypted() async {
        let container = stubContainer()
        container.isEncryptedHandler = { true }
        await viewModel.loadContainerData(cryptoContainer: container)

        await viewModel.updateAsyncProperties()

        #expect(viewModel.isDecryptButtonShown == true)
        #expect(viewModel.isDecryptionUnavailable == false)
    }

    @Test
    func isDecryptionUnavailable_isTrueForANestedEncryptedContainer() async {
        let container = stubContainer()
        container.isEncryptedHandler = { true }
        mockSharedContainerViewModel.isNestedContainerHandler = { _ in true }
        await viewModel.loadContainerData(cryptoContainer: container)

        await viewModel.updateAsyncProperties()

        #expect(viewModel.isDecryptButtonShown == false)
        #expect(viewModel.isDecryptionUnavailable == true)
    }

    @Test
    func isDecryptionUnavailable_isFalseWhenTheContainerIsNotEncrypted() async {
        _ = stubContainer()
        mockSharedContainerViewModel.isNestedContainerHandler = { _ in true }
        await viewModel.loadContainerData(cryptoContainer: nil)

        await viewModel.updateAsyncProperties()

        #expect(viewModel.isDecryptionUnavailable == false)
    }

    @Test
    func isContainerEncryptedOrDecrypted_isTrueWhenTheContainerIsEncrypted() async {
        let container = stubContainer()
        container.isEncryptedHandler = { true }
        await viewModel.loadContainerData(cryptoContainer: container)

        await viewModel.updateAsyncProperties()

        #expect(viewModel.isContainerEncryptedOrDecrypted == true)
    }

    @Test
    func isContainerEncryptedOrDecrypted_isTrueWhenTheContainerIsDecrypted() async {
        let container = stubContainer()
        container.isDecryptedHandler = { true }
        await viewModel.loadContainerData(cryptoContainer: container)

        await viewModel.updateAsyncProperties()

        #expect(viewModel.isContainerEncryptedOrDecrypted == true)
    }

    @Test
    func isContainerEncryptedOrDecrypted_recomputesWhenTheContainerIsNoLongerEncrypted() async {
        let encrypted = stubContainer()
        encrypted.isEncryptedHandler = { true }
        await viewModel.loadContainerData(cryptoContainer: encrypted)
        await viewModel.updateAsyncProperties()

        #expect(viewModel.isContainerEncryptedOrDecrypted == true)

        await viewModel.loadContainerData(cryptoContainer: stubContainer())
        await viewModel.updateAsyncProperties()

        #expect(viewModel.isContainerEncryptedOrDecrypted == false)
    }
}
