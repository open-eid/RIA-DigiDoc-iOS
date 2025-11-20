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
import ConfigLibMocks
import MobileIdLib
import MobileIdLibMocks

@MainActor
struct MobileIdViewModelTests {

    private let mockConfigurationRepository: ConfigurationRepositoryProtocolMock
    private let mockMobileIdSignService: MobileIdSignServiceProtocolMock
    private let mockCertificatUtil: CertificateUtilProtocolMock
    private let mockDataStore: DataStoreProtocolMock

    private let viewModel: MobileIdViewModel

    init() async throws {
        self.mockConfigurationRepository = ConfigurationRepositoryProtocolMock()
        self.mockMobileIdSignService = MobileIdSignServiceProtocolMock()
        self.mockCertificatUtil = CertificateUtilProtocolMock()
        self.mockDataStore = DataStoreProtocolMock()

        viewModel = MobileIdViewModel(
            configurationRepository: mockConfigurationRepository,
            mobileIdSignService: mockMobileIdSignService,
            certificateUtil: mockCertificatUtil,
            dataStore: mockDataStore
        )
    }

    @Test
    func isRoleDataEnabled_successWithTrue() async {
        mockDataStore.getIsRoleAndAddressEnabledHandler = { true }

        let isRoleAndAddressEnabled = await viewModel.isRoleDataEnabled()

        #expect(isRoleAndAddressEnabled)
    }

    @Test
    func isRoleDataEnabled_successWithFalse() async {
        mockDataStore.getIsRoleAndAddressEnabledHandler = { false }

        let isRoleAndAddressEnabled = await viewModel.isRoleDataEnabled()

        #expect(!isRoleAndAddressEnabled)
    }
}
