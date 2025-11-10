import SwiftUI
import FactoryKit
import LibdigidocLibSwift

struct SigningRootView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var chosenMethod: SigningMethod = .idCardViaNFC

    @StateObject private var viewModel: SigningRootViewModel

    let signedContainer: SignedContainerProtocol
    let onSuccess: (SignedContainerProtocol) -> Void

    init(
        signedContainer: SignedContainerProtocol,
        onSuccess: @escaping (SignedContainerProtocol) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: Container.shared.signingRootViewModel())
        self.signedContainer = signedContainer
        self.onSuccess = onSuccess
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
                MobileIdView(
                    signedContainer: signedContainer,
                    onSuccess: onSuccess
                )
            case .smartId:
                SmartIdView(
                    signedContainer: signedContainer,
                    onSuccess: onSuccess
                )
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
    SigningRootView(
        signedContainer: SignedContainer(
            fileManager: Container.shared.fileManager(),
            containerUtil: Container.shared.containerUtil()
        ),
        onSuccess: {_ in }
    )
}
