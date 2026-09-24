// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
