import SwiftUI

struct ContentView: View {
    let someViewModel = AppAssembler.shared.resolve(SomeViewModel.self)

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()

        SomeView(viewModel: someViewModel)
    }
}

#Preview {
    ContentView()
}
