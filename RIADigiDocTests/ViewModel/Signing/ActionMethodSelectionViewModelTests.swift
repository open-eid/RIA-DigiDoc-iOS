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

@MainActor
final class ActionMethodSelectionViewModelTests {

    private let mockDataStore: DataStoreProtocolMock

    private let viewModel: ActionMethodSelectionViewModel

    init() {
        mockDataStore = DataStoreProtocolMock()

        viewModel = ActionMethodSelectionViewModel(dataStore: mockDataStore)
    }

    @Test
    func setSelectedSigningMethod_success() async {
        mockDataStore.setSelectedSigningMethodHandler = { _ in }

        await viewModel.setSelectedSigningMethod(.mobileId)

        #expect(mockDataStore.setSelectedSigningMethodCallCount == 1)
    }

    @Test
    func getSelectedSigningMethod_success() async {
        mockDataStore.getSelectedSigningMethodHandler = { .smartId }

        let result = await viewModel.getSelectedSigningMethod()

        #expect(result == .smartId)
    }

    @Test
    func setSelectedMyEidMethod_success() async {
        mockDataStore.setSelectedMyEidMethodHandler = { _ in }

        await viewModel.setSelectedMyEidMethod(.idCardViaUSB)

        #expect(mockDataStore.setSelectedMyEidMethodCallCount == 1)
    }

    @Test
    func getSelectedMyEidMethod_success() async {
        let actionMethod: ActionMethod = .idCardViaUSB

        mockDataStore.getSelectedMyEidMethodHandler = { actionMethod }

        let result = await viewModel.getSelectedMyEidMethod()

        #expect(result == actionMethod)
    }
}
