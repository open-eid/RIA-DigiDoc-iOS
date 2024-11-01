import Foundation

public protocol DigiDocConfProtocol: Sendable {
    static func initDigiDoc() async throws(DigiDocError)
}
