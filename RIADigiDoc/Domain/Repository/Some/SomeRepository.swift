import Foundation

actor SomeRepository: SomeRepositoryProtocol {
    func fetchSomeObject() async -> SomeObject {
        return SomeObject(id: 1, name: "Some Name")
    }
}
