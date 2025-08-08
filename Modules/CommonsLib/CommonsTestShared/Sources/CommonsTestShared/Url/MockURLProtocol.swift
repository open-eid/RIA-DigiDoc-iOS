// swiftlint:disable static_over_final_class unused_parameter

import Foundation
import OSLog
import Alamofire

public final class MockURLProtocol: URLProtocol {
    public typealias Handler = @Sendable (URLRequest) throws -> (HTTPURLResponse, Data)
    static let handlerKey = "MockURLProtocol.HandlerKey"

    public override class func canInit(with request: URLRequest) -> Bool {
        return URLProtocol.property(forKey: handlerKey, in: request) != nil
    }

    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    public override func startLoading() {
        guard let client = client else { return }

        guard let handler = URLProtocol.property(forKey: Self.handlerKey, in: request) as? Handler else {
            client.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }

        do {
            let (response, data) = try handler(request)
            client.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client.urlProtocol(self, didLoad: data)
            client.urlProtocolDidFinishLoading(self)
        } catch {
            client.urlProtocol(self, didFailWithError: error)
        }
    }

    public override func stopLoading() { }
}

final class MockInterceptor: RequestInterceptor {
    private static let logger = Logger(
        subsystem: "ee.ria.digidoc.RIADigiDoc.CommonsTestShared",
        category: "MockInterceptor"
    )

    let handler: MockURLProtocol.Handler

    init(handler: @escaping MockURLProtocol.Handler) {
        self.handler = handler
    }

    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        let mutableRequest = (urlRequest as NSURLRequest).mutableCopy() as? NSMutableURLRequest

        guard let request = mutableRequest else {
            MockInterceptor.logger.error("Unable to get mutable URLRequest")
            return
        }

        URLProtocol.setProperty(handler, forKey: MockURLProtocol.handlerKey, in: request)
        completion(.success(request as URLRequest))
    }
}

public func makeMockedSession(handler: @escaping MockURLProtocol.Handler) -> Session {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]

    return Session(configuration: config, interceptor: MockInterceptor(handler: handler))
}

// swiftlint:enable static_over_final_class unused_parameter
