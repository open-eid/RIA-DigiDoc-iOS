import SwiftUI

struct SaveButton: View {
    @EnvironmentObject var languageSettings: LanguageSettings

    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "square.and.arrow.down")
                    .accessibilityLabel(languageSettings.localized("Save"))
            }
            .foregroundColor(.black)
            .padding(4)
            .cornerRadius(10)
        }
        .padding(.horizontal, 10)
        .buttonStyle(PlainButtonStyle())
    }
}
