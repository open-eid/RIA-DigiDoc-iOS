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
import CommonsLib

@MainActor
struct RoleViewModelTests {

    private let mockDataStore: DataStoreProtocolMock

    private let viewModel: RoleViewModel

    init() async throws {
        self.mockDataStore = DataStoreProtocolMock()

        viewModel = RoleViewModel(dataStore: mockDataStore)
    }

    @Test
    func saveInputData_success() async {
        let roleData = RoleData(
            roles: ["Role 1", "Role 2"],
            city: "Test City",
            state: "Test State",
            country: "Test Country",
            zipCode: "Test zip code"
        )

        await viewModel.saveInputData(roleData)

        #expect(mockDataStore.setRoleDataCallCount == 1)

        let argumentValues = mockDataStore.setRoleDataArgValues.first

        guard let values = argumentValues else {
            Issue.record("Expected valid RoleData argument values")
            return
        }

        #expect(roleData.roles == values.roles)
        #expect(roleData.city == values.city)
        #expect(roleData.state == values.state)
        #expect(roleData.country == values.country)
        #expect(roleData.zipCode == values.zipCode)
    }

    @Test
    func getInputData_successWithFalse() async {
        let roleData = RoleData(
            roles: ["Role 1", "Role 2"],
            city: "Test City",
            state: "Test State",
            country: "Test Country",
            zipCode: "Test zip code"
        )

        mockDataStore.getRoleDataHandler = { roleData }

        let savedRoleData = await viewModel.getInputData()

        #expect(savedRoleData.roles == roleData.roles)
        #expect(savedRoleData.city == roleData.city)
        #expect(savedRoleData.state == roleData.state)
        #expect(savedRoleData.country == roleData.country)
        #expect(savedRoleData.zipCode == roleData.zipCode)
    }
}
