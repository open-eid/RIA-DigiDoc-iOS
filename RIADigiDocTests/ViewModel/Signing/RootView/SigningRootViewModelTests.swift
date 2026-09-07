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
import LibdigidocLibSwift
import CommonsLibMocks
import UtilsLibMocks

@MainActor
struct SigningRootViewModelTests {
    private let mockDataStore: DataStoreProtocolMock
    private let mockFileManager: FileManagerProtocolMock
    private let mockContainerUtil: ContainerUtilProtocolMock
    private let sharedContainerViewModel: SharedContainerViewModel
    private let viewModel: SigningRootViewModel

    init() async throws {
        mockDataStore = DataStoreProtocolMock()
        mockFileManager = FileManagerProtocolMock()
        mockContainerUtil = ContainerUtilProtocolMock()
        sharedContainerViewModel = SharedContainerViewModel()
        viewModel = SigningRootViewModel(
            dataStore: mockDataStore,
            sharedContainerViewModel: sharedContainerViewModel
        )
    }

    private func makeSignedContainer() -> SignedContainer {
        SignedContainer(
            fileManager: mockFileManager,
            containerUtil: mockContainerUtil
        )
    }

    @Test
    func applySignedContainer_replacesContainerWhenItIsStillTheOpenOne() async {
        let containerBeingSigned = makeSignedContainer()
        sharedContainerViewModel.setSignedContainer(containerBeingSigned)
        let signedContainer = makeSignedContainer()

        viewModel.applySignedContainer(signedContainer, replacing: containerBeingSigned)

        #expect(sharedContainerViewModel.currentContainer() === signedContainer)
        #expect(sharedContainerViewModel.containers().count == 1)
        #expect(sharedContainerViewModel.getIsSignatureAdded())
    }

    @Test
    func applySignedContainer_dropsResultWhenContainersWereCleared() async {
        let containerBeingSigned = makeSignedContainer()
        sharedContainerViewModel.setSignedContainer(containerBeingSigned)
        sharedContainerViewModel.clearContainers()
        let signedContainer = makeSignedContainer()

        viewModel.applySignedContainer(signedContainer, replacing: containerBeingSigned)

        #expect(sharedContainerViewModel.containers().isEmpty)
        #expect(!sharedContainerViewModel.getIsSignatureAdded())
    }

    @Test
    func applySignedContainer_dropsResultWhenAnotherContainerWasOpened() async {
        let containerBeingSigned = makeSignedContainer()
        sharedContainerViewModel.setSignedContainer(containerBeingSigned)
        sharedContainerViewModel.clearContainers()

        let externallyOpenedContainer = makeSignedContainer()
        sharedContainerViewModel.setSignedContainer(externallyOpenedContainer)

        let signedContainer = makeSignedContainer()

        viewModel.applySignedContainer(signedContainer, replacing: containerBeingSigned)

        #expect(sharedContainerViewModel.currentContainer() === externallyOpenedContainer)
        #expect(sharedContainerViewModel.containers().count == 1)
        #expect(!sharedContainerViewModel.getIsSignatureAdded())
    }

    @Test
    func applySignedContainer_dropsResultWhenThereWasNoContainerBeingSigned() async {
        let externallyOpenedContainer = makeSignedContainer()
        sharedContainerViewModel.setSignedContainer(externallyOpenedContainer)
        let signedContainer = makeSignedContainer()

        viewModel.applySignedContainer(signedContainer, replacing: nil)

        #expect(sharedContainerViewModel.currentContainer() === externallyOpenedContainer)
        #expect(!sharedContainerViewModel.getIsSignatureAdded())
    }
}
