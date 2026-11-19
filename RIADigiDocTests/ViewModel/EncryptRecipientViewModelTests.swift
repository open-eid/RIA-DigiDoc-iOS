// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import CommonsLib
import CryptoObjCWrapper
import CryptoSwift
import Foundation
import Synchronization
import Testing

@MainActor
struct EncryptRecipientViewModelTests {

    private let mockSharedContainerViewModel: SharedContainerViewModelProtocolMock
    private let mockLdapSearch: LdapSearchProtocolMock
    private let viewModel: EncryptRecipientViewModel

    init() {
        mockSharedContainerViewModel = SharedContainerViewModelProtocolMock()
        mockLdapSearch = LdapSearchProtocolMock()
        viewModel = EncryptRecipientViewModel(
            sharedContainerViewModel: mockSharedContainerViewModel,
            ldapSearch: mockLdapSearch
        )
    }

    @Test
    func loadRecipients_showNoInternetConnectionWhenLdapServerIsUnreachable() async {
        mockLdapSearch.searchHandler = { _ in
            LdapSearchResult(addressees: [], tooManyResults: false, isNetworkError: true)
        }

        viewModel.searchText = "60001019906"
        await viewModel.loadRecipients()

        #expect(viewModel.recipients.isEmpty)
        #expect(viewModel.errorMessage?.key == "No Internet connection")
        #expect(viewModel.emptyStateMessageKey == "No Internet connection")
    }

    @Test
    func loadRecipients_showNoValidCertificateWhenSearchCompletesWithNoResults() async {
        mockLdapSearch.searchHandler = { _ in
            LdapSearchResult(addressees: [], tooManyResults: false, isNetworkError: false)
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

        mockLdapSearch.searchHandler = { _ in
            LdapSearchResult(addressees: [addressee], tooManyResults: false, isNetworkError: true)
        }

        viewModel.searchText = "60001019906"
        await viewModel.loadRecipients()

        #expect(viewModel.recipients.count == 1)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.emptyStateMessageKey == nil)
    }

    @Test
    func handleSearchTextChange_clearsEmptyStateFromThePreviousSearch() async {
        mockLdapSearch.searchHandler = { _ in
            LdapSearchResult(addressees: [], tooManyResults: false, isNetworkError: true)
        }

        viewModel.searchText = "60001019906"
        await viewModel.loadRecipients()
        #expect(viewModel.emptyStateMessageKey == "No Internet connection")

        viewModel.handleSearchTextChange()

        #expect(viewModel.emptyStateMessageKey == nil)
        #expect(viewModel.recipients.isEmpty)
    }

    @Test
    func loadRecipients_ignoresResultOfOutdatedSearch() async {
        let outdatedAddressee = Addressee(data: Data([0x01]), cnVal: "TESTNUMBER,SEITSMES,60001019906")
        let currentAddressee = Addressee(data: Data([0x02]), cnVal: "TESTNUMBER,KAHEKSAS,60001019917")
        let (started, startedContinuation) = AsyncStream<Void>.makeStream()
        let (release, releaseContinuation) = AsyncStream<Void>.makeStream()

        mockLdapSearch.searchHandler = { identityCode in
            guard identityCode == "60001019906" else {
                return LdapSearchResult(addressees: [currentAddressee], tooManyResults: false)
            }
            startedContinuation.yield()
            for await _ in release { break }
            return LdapSearchResult(addressees: [outdatedAddressee], tooManyResults: false)
        }

        viewModel.searchText = "60001019906"
        let outdatedSearch = Task { await viewModel.loadRecipients() }
        for await _ in started { break }

        viewModel.searchText = "60001019917"
        viewModel.handleSearchTextChange()
        await viewModel.loadRecipients()
        releaseContinuation.yield()
        await outdatedSearch.value

        #expect(viewModel.recipients.map(\.data) == [currentAddressee.data])
        #expect(viewModel.errorMessage == nil)
    }

    @Test
    func loadRecipients_ignoresResultWhenQueryIsEditedDuringSearch() async {
        let (started, startedContinuation) = AsyncStream<Void>.makeStream()
        let (release, releaseContinuation) = AsyncStream<Void>.makeStream()

        mockLdapSearch.searchHandler = { _ in
            startedContinuation.yield()
            for await _ in release { break }
            return LdapSearchResult(addressees: [], tooManyResults: false, isNetworkError: true)
        }

        viewModel.searchText = "60001019906"
        let search = Task { await viewModel.loadRecipients() }
        for await _ in started { break }

        viewModel.searchText = "6000101990"
        releaseContinuation.yield()
        await search.value

        #expect(viewModel.recipients.isEmpty)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.emptyStateMessageKey == nil)
    }

    @Test
    func loadRecipients_ignoresOlderResultForSameQuery() async {
        let addressee = Addressee(data: Data([0x01]), cnVal: "TESTNUMBER,SEITSMES,60001019906")
        let callCount = Mutex(0)
        let (started, startedContinuation) = AsyncStream<Void>.makeStream()
        let (release, releaseContinuation) = AsyncStream<Void>.makeStream()

        mockLdapSearch.searchHandler = { _ in
            let call = callCount.withLock { count in
                count += 1
                return count
            }
            guard call == 1 else {
                return LdapSearchResult(addressees: [addressee], tooManyResults: false)
            }
            startedContinuation.yield()
            for await _ in release { break }
            return LdapSearchResult(addressees: [], tooManyResults: false, isNetworkError: true)
        }

        viewModel.searchText = "60001019906"
        let olderSearch = Task { await viewModel.loadRecipients() }
        for await _ in started { break }

        await viewModel.loadRecipients()
        releaseContinuation.yield()
        await olderSearch.value

        #expect(viewModel.recipients.map(\.data) == [addressee.data])
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.emptyStateMessageKey == nil)
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
