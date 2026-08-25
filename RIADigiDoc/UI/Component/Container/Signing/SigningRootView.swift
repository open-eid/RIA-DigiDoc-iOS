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

import SwiftUI
import FactoryKit
import nfclib
import LibdigidocLibSwift
import CommonsLib

struct SigningRootView: View {
    @Environment(\.dismiss) private var dismiss

    @Environment(NavigationPathManager.self) private var pathManager

    @State private var chosenMethod: ActionMethod = .idCardViaNFC
    @State private var isSuccess = false

    @State private var viewModel: SigningRootViewModel

    private let signedContainer: GeneralContainer?

    private let sharedContainerViewModel: SharedContainerViewModelProtocol

    init() {
        _viewModel = State(wrappedValue: Container.shared.signingRootViewModel())
        self.sharedContainerViewModel = Container.shared.sharedContainerViewModel()
        self.signedContainer = sharedContainerViewModel.currentContainer()
    }

    var body: some View {
        ZStack {
            switch chosenMethod {
            case .idCardViaNFC:
                if let container = signedContainer as? SignedContainerProtocol {
                    NFCView(
                        actionType: .signing,
                        actionMethods: [
                            .idCardViaNFC,
                            .mobileId,
                            .smartId
                        ],
                        pinType: CodeType.pin2,
                        isWebEidAuthenticating: .constant(false),
                        signedContainer: container,
                        onSuccess: { container in
                            isSuccess = true
                            sharedContainerViewModel.removeLastContainer()
                            sharedContainerViewModel.setSignedContainer(container)
                            sharedContainerViewModel.setIsSignatureAdded(true)
                        }
                    )
                }
            case .mobileId:
                if let container = signedContainer as? SignedContainerProtocol {
                    MobileIdView(
                        signedContainer: container,
                        onSuccess: { container in
                            sharedContainerViewModel.removeLastContainer()
                            sharedContainerViewModel.setSignedContainer(container)
                            sharedContainerViewModel.setIsSignatureAdded(true)
                        }
                    )
                }
            case .smartId:
                if let container = signedContainer as? SignedContainerProtocol {
                    SmartIdView(
                        signedContainer: container,
                        onSuccess: { container in
                            sharedContainerViewModel.removeLastContainer()
                            sharedContainerViewModel.setSignedContainer(container)
                            sharedContainerViewModel.setIsSignatureAdded(true)
                        }
                    )
                }
            }
        }
        .onAppear {
            Task {
                chosenMethod = await viewModel.getSelectedSigningMethod()
            }
        }
    }
}

#Preview {
    SigningRootView()
        .environment(Container.shared.languageSettings())
        .environment(Container.shared.themeSettings())
        .environment(NavigationPathManager())
}
