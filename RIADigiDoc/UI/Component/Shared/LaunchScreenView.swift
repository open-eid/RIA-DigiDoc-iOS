import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 160)
                .accessibilityLabel("Logo")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    LaunchScreenView()
}
