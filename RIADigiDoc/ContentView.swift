import SwiftUI

struct ContentView: View {
    let someViewModel = AppAssembler.shared.resolve(SomeViewModel.self)

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .accessibilityLabel("Globe")
            Text("Hello, world!")
        }
        .padding()

        SomeView(viewModel: someViewModel)
    }
}

#Preview {
    ContentView()
}
