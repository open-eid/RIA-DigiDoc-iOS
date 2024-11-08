import Foundation

actor SomeService: SomeServiceProtocol {
    func fetchSomeObject() async -> SomeObject {
        return SomeObject(id: 1, name: "Some Name")
    }
}
