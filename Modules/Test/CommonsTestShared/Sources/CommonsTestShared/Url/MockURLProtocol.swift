/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

// swiftlint:disable static_over_final_class unused_parameter

import Foundation
import OSLog
import Alamofire

public final class MockURLProtocol: URLProtocol {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.CommonsTestShared", category: "MockURLProtocol")

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
    private static let logger = Logger(subsystem: "ee.ria.digidoc.CommonsTestShared", category: "MockInterceptor")

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
