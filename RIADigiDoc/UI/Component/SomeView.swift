import SwiftUI

struct SomeView: View {
    @StateObject private var viewModel: SomeViewModel

    init(
        viewModel: SomeViewModel = AppAssembler.shared.resolve(SomeViewModel.self)
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

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
    SomeView()
}
