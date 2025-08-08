import Foundation

/// @mockable
public protocol URLProtocolProtocol: Sendable {
    func handle(for request: URLRequest) async throws -> (HTTPURLResponse, Data?)
}

public final class URLSessionHandler: URLProtocolProtocol {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func handle(for request: URLRequest) async throws -> (HTTPURLResponse, Data?) {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        return (httpResponse, data)
    }
}
