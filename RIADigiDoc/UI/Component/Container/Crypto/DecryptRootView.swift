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

import SwiftUI
import FactoryKit
import CryptoSwift
import IdCardLib
import CommonsLib

struct DecryptRootView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageSettings.self) private var languageSettings
    @Environment(NavigationPathManager.self) private var pathManager

    @State private var chosenMethod: ActionMethod = .idCardViaNFC

    @State private var viewModel: DecryptRootViewModel

    private let cryptoContainer: GeneralContainer?

    private let sharedContainerViewModel: SharedContainerViewModelProtocol

    init() {
        _viewModel = State(wrappedValue: Container.shared.decryptRootViewModel())
        self.sharedContainerViewModel = Container.shared.sharedContainerViewModel()
        self.cryptoContainer = sharedContainerViewModel.currentContainer()
    }

    var body: some View {
        ZStack {
            switch chosenMethod {
            case .idCardViaNFC:
                if let container = cryptoContainer as? CryptoContainerProtocol {
                    NFCView(
                        actionType: .decrypt,
                        actionMethods: [
                            .idCardViaNFC,
                            .idCardViaUSB
                        ],
                        pinType: CodeType.pin1,
                        cryptoContainer: container,
                        onSuccessDecrypt: { container in
                            sharedContainerViewModel.removeLastContainer()
                            sharedContainerViewModel.setCryptoContainer(container)
                            
                            Toast.show(languageSettings.localized(
                                "Container successfully decrypted"
                            ))
                        }
                    )
                }
            case .idCardViaUSB:
                if let container = cryptoContainer as? CryptoContainerProtocol {
                    IdCardView(
                        actionType: .decrypt,
                        actionMethods: [
                            .idCardViaNFC,
                            .idCardViaUSB
                        ],
                        cryptoContainer: container,
                        onSuccess: { container in
                            sharedContainerViewModel.removeLastContainer()
                            sharedContainerViewModel.setSignedContainer(container)
                        }
                    )
                }
            case .mobileId:
                EmptyView()
            case .smartId:
                EmptyView()
            }
        }
        .onAppear {
            Task {
                chosenMethod = await viewModel.getSelectedDecryptMethod()
            }
        }
    }
}

#Preview {
    DecryptRootView()
}
