import Foundation

actor SomeRepository: SomeRepositoryProtocol {
    private let someService: SomeServiceProtocol

    init(someService: SomeServiceProtocol) {
        self.someService = someService
    }

    func fetchSomeObject() async -> SomeObject {
        return await someService.fetchSomeObject()
    }
}
