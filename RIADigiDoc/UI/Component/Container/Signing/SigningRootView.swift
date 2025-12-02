import SwiftUI
import FactoryKit
import LibdigidocLibSwift
import CommonsLib

struct SigningRootView: View {
    @Environment(\.dismiss) private var dismiss

    @Environment(NavigationPathManager.self) private var pathManager

    @State private var chosenMethod: SigningMethod = .idCardViaNFC

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
                // TODO: Replace with ID-card NFC view
                SignatureInputScreen(
                    selectedSigningMethod: "ID-card via NFC",
                    isSigningEnabled: .constant(false),
                    isSigning: .constant(false),
                    onBackClick: { dismiss() },
                    onSign: {},
                    content: {
                        EmptyView()
                    }
                )
            case .idCardViaUSB:
                // TODO: Replace with ID-card USB view
                SignatureInputScreen(
                    selectedSigningMethod: "ID-card via USB",
                    isSigningEnabled: .constant(false),
                    isSigning: .constant(false),
                    onBackClick: { dismiss() },
                    onSign: {},
                    content: {
                        EmptyView()
                    }
                )
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
}
