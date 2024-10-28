import SwiftUI

struct SomeView: View {
    @ObservedObject var viewModel: SomeViewModel

    var body: some View {
        VStack {
            if let someObject = viewModel.someObject {
                Text("Name: \(someObject.name)")
            } else {
                Text("Loading...")
            }
        } .onAppear {
            Task {
                await viewModel.getSomeObject()
            }
        }
    }
}

#Preview {
    let someViewModel = AppAssembler.shared.resolve(SomeViewModel.self)
    SomeView(viewModel: someViewModel)
}
