// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
