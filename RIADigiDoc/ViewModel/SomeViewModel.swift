import Foundation

@MainActor
class SomeViewModel: ObservableObject {
    @Published var someObject: SomeObject?

    private let someService: SomeServiceProtocol

    init(someService: SomeServiceProtocol) {
        self.someService = someService
    }

    func getSomeObject() async {
        someObject = await someService.fetchSomeObject()
    }
}
