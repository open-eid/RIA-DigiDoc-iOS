// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Testing
import Foundation
import Alamofire
import CommonsLib
import SmartIdLibMocks

@testable import SmartIdLib

struct SessionProviderTests {

    private let validURL = "https://url.test"
    private let invalidURL = "not-a-url"
    private let certificates: [SecCertificate] = []

    private let provider: SessionProviderProtocol

    init() async throws {
        provider = SessionProvider()
    }

    @Test
    func ensureSession_success() async throws {
        let proxy = ProxyInfo()

        let session = try await provider.ensureSession(
            url: validURL,
            trustedCertificates: certificates,
            proxyInfo: proxy,
            userAgent: "TestUserAgent"
        )

        #expect(
            session.sessionConfiguration.timeoutIntervalForRequest == TimeInterval(
                Constants.Signing.Timeout
            )
        )
    }

    @Test
    func ensureSession_returnsCachedSessionWithTheSameProxy() async throws {
        let proxy = ProxyInfo()

        let first = try await provider.ensureSession(
            url: validURL,
            trustedCertificates: certificates,
            proxyInfo: proxy,
            userAgent: "TestUserAgent"
        )

        let second = try await provider.ensureSession(
            url: validURL,
            trustedCertificates: certificates,
            proxyInfo: proxy,
            userAgent: "TestUserAgent"
        )

        #expect(first === second)
    }

    @Test
    func ensureSession_createsNewSessionWithDifferentProxy() async throws {
        let firstProxy = ProxyInfo()
        let secondProxy = ProxyInfo(host: "127.0.0.1", port: 8888)

        let first = try await provider.ensureSession(
            url: validURL,
            trustedCertificates: certificates,
            proxyInfo: firstProxy,
            userAgent: "TestUserAgent"
        )

        let second = try await provider.ensureSession(
            url: validURL,
            trustedCertificates: certificates,
            proxyInfo: secondProxy,
            userAgent: "TestUserAgent"
        )

        #expect(first !== second)
    }

    @Test
    func ensureSession_throwsBadURLWithInvalidURL() async {
        let proxy = ProxyInfo()

        do {
            _ = try await provider.ensureSession(
                url: invalidURL,
                trustedCertificates: certificates,
                proxyInfo: proxy,
                userAgent: "TestUserAgent"
            )
            Issue.record("Expected to throw URLError")
            return
        } catch let error as URLError {
            #expect(error.code == .badURL)
        } catch {
            Issue.record("Expected to throw URLError")
            return
        }

    }

    @Test
    func ensureSession_updatesCachedProxy() async throws {
        let firstProxy = ProxyInfo()
        let secondProxy = ProxyInfo(
            host: "localhost",
            port: 8080
        )

        _ = try await provider.ensureSession(
            url: validURL,
            trustedCertificates: certificates,
            proxyInfo: firstProxy,
            userAgent: "TestUserAgent"
        )

        let newSession = try await provider.ensureSession(
            url: validURL,
            trustedCertificates: certificates,
            proxyInfo: secondProxy,
            userAgent: "TestUserAgent"
        )

        let cachedSession = try await provider.ensureSession(
            url: validURL,
            trustedCertificates: certificates,
            proxyInfo: secondProxy,
            userAgent: "TestUserAgent"
        )

        #expect(newSession === cachedSession)
    }
}
