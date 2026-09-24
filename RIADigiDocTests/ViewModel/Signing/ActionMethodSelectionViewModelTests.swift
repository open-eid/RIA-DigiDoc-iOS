// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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

        await viewModel.setSelectedMyEidMethod(.idCardViaNFC)

        #expect(mockDataStore.setSelectedMyEidMethodCallCount == 1)
    }

    @Test
    func getSelectedMyEidMethod_success() async {
        let actionMethod: ActionMethod = .idCardViaNFC

        mockDataStore.getSelectedMyEidMethodHandler = { actionMethod }

        let result = await viewModel.getSelectedMyEidMethod()

        #expect(result == actionMethod)
    }
}
