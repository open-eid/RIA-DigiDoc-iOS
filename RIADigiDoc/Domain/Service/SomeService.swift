import Foundation

actor SomeService: SomeServiceProtocol {
    private let someRepository: SomeRepositoryProtocol

    init(someRepository: SomeRepositoryProtocol) {
        self.someRepository = someRepository
    }

    func fetchSomeObject() async -> SomeObject {
        return await someRepository.fetchSomeObject()
    }
}
