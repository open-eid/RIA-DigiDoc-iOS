import SwiftUI

struct LoadingView: View {
    @EnvironmentObject var languageSettings: LanguageSettings

    @State private var isLoading: Bool = false
    @State private var rotationAngle: Double = 0

    var body: some View {
        ZStack {
            Image("Spinner")
                .resizable()
                .frame(width: 100, height: 100)
                .rotationEffect(.degrees(rotationAngle))
                .accessibilityLabel(languageSettings.localized("Loading"))
                .onChange(of: isLoading) { _ in
                    withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                        rotationAngle += 360
                    }
                }
                .onAppear {
                    isLoading = true
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    LoadingView()
}
