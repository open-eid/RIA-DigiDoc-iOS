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
