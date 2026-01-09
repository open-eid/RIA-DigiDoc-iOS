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

import UtilsLib
import Foundation

@Observable
@MainActor
class ActionMethodSelectionViewModel: ActionMethodSelectionViewModelProtocol, Loggable {
    private let dataStore: DataStoreProtocol

    init(dataStore: DataStoreProtocol) {
        self.dataStore = dataStore
    }

    func setSelectedSigningMethod(_ method: ActionMethod) async {
        await dataStore.setSelectedSigningMethod(method)
    }

    func getSelectedSigningMethod() async -> ActionMethod {
        await dataStore.getSelectedSigningMethod()
    }

    func setSelectedMyEidMethod(_ method: ActionMethod) async {
        await dataStore.setSelectedMyEidMethod(method)
    }

    func getSelectedMyEidMethod() async -> ActionMethod {
        await dataStore.getSelectedMyEidMethod()
    }

    func setSelectedDecryptMethod(_ method: ActionMethod) async {
        await dataStore.setSelectedDecryptMethod(method)
    }

    func getSelectedDecryptMethod() async -> ActionMethod {
        await dataStore.getSelectedDecryptMethod()
    }
}
