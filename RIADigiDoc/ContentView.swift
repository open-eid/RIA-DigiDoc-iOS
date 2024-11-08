import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Image(systemName: "globe")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                        .accessibilityLabel("Globe")
                    Text("Hello, world!")
                }
                .padding()

                SomeView()

                MainSignatureView()
            }
        }
    }
}

#Preview {
    ContentView()
}
