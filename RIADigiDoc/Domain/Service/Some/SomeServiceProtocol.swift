import Foundation

protocol SomeServiceProtocol: Sendable {
    func fetchSomeObject() async -> SomeObject
}
