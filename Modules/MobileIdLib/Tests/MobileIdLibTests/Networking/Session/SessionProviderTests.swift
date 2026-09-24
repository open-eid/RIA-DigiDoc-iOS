// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import Testing
import CommonsLib
import MobileIdLibMocks

@testable import MobileIdLib

struct SessionProviderTests {

    private let provider: SessionProviderProtocol

    init() async throws {
        provider = SessionProvider()
    }

    @Test
    func ensureSession_success() async throws {
        let session = try await provider.ensureSession(
            url: "https://url.test",
            trustedCertificates: [],
            proxyInfo: ProxyInfo(),
            userAgent: "SessionProviderTestsUserAgent"
        )

        #expect(
            session.sessionConfiguration.timeoutIntervalForRequest == TimeInterval(
                Constants.Signing.Timeout
            )
        )

        #expect(
            session.sessionConfiguration.timeoutIntervalForResource == TimeInterval(
                Constants.Signing.Timeout
            )
        )

        #expect(
            session.sessionConfiguration.requestCachePolicy == .reloadIgnoringLocalAndRemoteCacheData
        )

        #expect(session.sessionConfiguration.urlCache == nil)
    }

    @Test
    func ensureSession_returnSameSessionWhenCalledTwice() async throws {
        let firstSessionCall = try await provider.ensureSession(
            url: "https://url.test",
            trustedCertificates: [],
            proxyInfo: ProxyInfo(),
            userAgent: "SessionProviderTestsUserAgent"
        )

        let secondSessionCall = try await provider.ensureSession(
            url: "https://url.test",
            trustedCertificates: [],
            proxyInfo: ProxyInfo(),
            userAgent: "SessionProviderTestsUserAgent"
        )

        #expect(firstSessionCall === secondSessionCall)
    }

    @Test
    func ensureSession_throwsBadURL_forInvalidURL() async {
        await #expect(throws: URLError.self) {
            try await provider.ensureSession(
                url: "invalid-url",
                trustedCertificates: [],
                proxyInfo: ProxyInfo(),
                userAgent: "SessionProviderTestsUserAgent"
            )
        }
    }
}
