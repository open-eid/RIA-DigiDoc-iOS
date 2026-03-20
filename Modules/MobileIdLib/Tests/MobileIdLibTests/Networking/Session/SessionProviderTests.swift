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
