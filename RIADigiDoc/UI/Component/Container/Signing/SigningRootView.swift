import SwiftUI

struct SigningRootView: View {

    private let chosenMethod: SigningMethod = .mobileId

    let onSuccess: () -> Void

    var body: some View {
        switch chosenMethod {
        case .idCardViaNFC:
            EmptyView()
        case .idCardViaUSB:
            EmptyView()
        case .mobileId:
            MobileIdView(onSuccess: onSuccess)
        case .smartId:
            EmptyView()
        }
    }
}

#Preview {
    SigningRootView(onSuccess: {})
}
