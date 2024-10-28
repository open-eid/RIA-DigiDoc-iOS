import Foundation

protocol SomeRepositoryProtocol: Sendable {
    func fetchSomeObject() async -> SomeObject
}
