import SwiftUI

struct JailbreakView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppTheme private var theme
    @AppTypography private var typography
    @EnvironmentObject var languageSettings: LanguageSettings

    var body: some View {
        VStack {
            Spacer()

            Text("This app cannot be used in jailbroken device")
                .foregroundStyle(theme.onSurface)
                .font(typography.bodyLarge)
                .padding()

            Spacer()
        }
    }
}

#Preview {
    JailbreakView()
}
