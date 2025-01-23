import SwiftUI

struct JailbreakView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var languageSettings: LanguageSettings

    var body: some View {
        VStack {
            Spacer()

            Text("This app cannot be used in jailbroken device")
                .font(.headline)
                .padding()

            Spacer()
        }
    }
}

#Preview {
    JailbreakView()
}
