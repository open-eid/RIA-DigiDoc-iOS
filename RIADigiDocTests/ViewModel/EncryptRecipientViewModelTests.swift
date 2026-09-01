// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import CommonsLib
import CryptoObjCWrapper
import CryptoSwift
import Foundation
import Testing

@MainActor
struct EncryptRecipientViewModelTests {

    private let mockSharedContainerViewModel: SharedContainerViewModelProtocolMock
    private let mockOpenLdap: OpenLdapProtocolMock
    private let viewModel: EncryptRecipientViewModel

    init() {
        mockSharedContainerViewModel = SharedContainerViewModelProtocolMock()
        mockOpenLdap = OpenLdapProtocolMock()
        viewModel = EncryptRecipientViewModel(
            sharedContainerViewModel: mockSharedContainerViewModel,
            openLdap: mockOpenLdap
        )
    }

    @Test
    func loadRecipients_showNoInternetConnectionWhenLdapServerIsUnreachable() async {
        mockOpenLdap.searchHandler = { _ in
            OpenLdapSearchResult(addressees: [], tooManyResults: false, isNetworkError: true)
        }

        viewModel.searchText = "60001019906"
        await viewModel.loadRecipients()

        #expect(viewModel.recipients.isEmpty)
        #expect(viewModel.errorMessage?.key == "No Internet connection")
        #expect(viewModel.emptyStateMessageKey == "No Internet connection")
    }

    @Test
    func loadRecipients_showNoValidCertificateWhenSearchCompletesWithNoResults() async {
        mockOpenLdap.searchHandler = { _ in
            OpenLdapSearchResult(addressees: [], tooManyResults: false, isNetworkError: false)
        }

        viewModel.searchText = "60001019906"
        await viewModel.loadRecipients()

        #expect(viewModel.recipients.isEmpty)
        #expect(viewModel.errorMessage?.key == "Person or company does not own a valid certificate")
        #expect(viewModel.emptyStateMessageKey == "Person or company does not own a valid certificate")
    }

    @Test
    func loadRecipients_showRecipientsWhenServerWasUnreachableButAnotherReturnedResults() async {
        let addressee = Addressee(data: Data([0x01]), cnVal: "TESTNUMBER,SEITSMES,60001019906")

        mockOpenLdap.searchHandler = { _ in
            OpenLdapSearchResult(addressees: [addressee], tooManyResults: false, isNetworkError: true)
        }

        viewModel.searchText = "60001019906"
        await viewModel.loadRecipients()

        #expect(viewModel.recipients.count == 1)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.emptyStateMessageKey == nil)
    }

    @Test
    func handleSearchTextChange_clearsEmptyStateFromThePreviousSearch() async {
        mockOpenLdap.searchHandler = { _ in
            OpenLdapSearchResult(addressees: [], tooManyResults: false, isNetworkError: true)
        }

        viewModel.searchText = "60001019906"
        await viewModel.loadRecipients()
        #expect(viewModel.emptyStateMessageKey == "No Internet connection")

        viewModel.handleSearchTextChange()

        #expect(viewModel.emptyStateMessageKey == nil)
        #expect(viewModel.recipients.isEmpty)
    }

    @Test
    func encryptWithPassword_successClearsAndSetsNewContainer() async throws {
        let mockContainer = CryptoContainerProtocolMock()
        let containerFile = URL(fileURLWithPath: "/tmp/test.cdoc")
        let dataFile = URL(fileURLWithPath: "/tmp/doc.pdf")
        mockSharedContainerViewModel.currentContainerHandler = { mockContainer }
        mockContainer.getRawContainerFileHandler = { containerFile }
        mockContainer.getDataFilesHandler = { [dataFile] }

        let resultContainer = CryptoContainerProtocolMock()
        viewModel.encryptWithPasswordAction = { _, _, _, _ in resultContainer }

        try await viewModel.encryptWithPassword(label: "testKey", password: "Abcdefgh1234567890123")

        #expect(mockSharedContainerViewModel.clearContainersCallCount == 1)
        #expect(mockSharedContainerViewModel.setCryptoContainerCallCount == 1)
    }

    @Test
    func encryptWithPassword_throwsWhenContainerIsNil() async {
        mockSharedContainerViewModel.currentContainerHandler = { nil }

        await #expect(throws: (any Error).self) {
            try await viewModel.encryptWithPassword(label: "testKey", password: "Abcdefgh1234567890123")
        }
    }

    @Test
    func encryptWithPassword_throwsWhenContainerFileIsNil() async {
        let mockContainer = CryptoContainerProtocolMock()
        mockSharedContainerViewModel.currentContainerHandler = { mockContainer }
        mockContainer.getRawContainerFileHandler = { nil }

        await #expect(throws: (any Error).self) {
            try await viewModel.encryptWithPassword(label: "testKey", password: "Abcdefgh1234567890123")
        }
    }

}
