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

struct WebEidUriUtilTests {

    private func makeURL(_ string: String) throws -> URL {
        try #require(URL(string: string))
    }

    @Test
    func isWebEidUri_appLinks_auth() throws {
        #expect(WebEidUriUtil.isWebEidUri(try makeURL("https://id.eesti.ee/auth")))
    }

    @Test
    func isWebEidUri_appLinks_cert() throws {
        #expect(WebEidUriUtil.isWebEidUri(try makeURL("https://id.eesti.ee/cert")))
    }

    @Test
    func isWebEidUri_appLinks_sign() throws {
        #expect(WebEidUriUtil.isWebEidUri(try makeURL("https://id.eesti.ee/sign")))
    }

    @Test
    func isWebEidUri_appLinks_unknownOperation() throws {
        #expect(!WebEidUriUtil.isWebEidUri(try makeURL("https://id.eesti.ee/unknown")))
    }

    @Test
    func isWebEidUri_wrongHost() throws {
        #expect(!WebEidUriUtil.isWebEidUri(try makeURL("https://evil.com/auth")))
    }

    @Test
    func isWebEidUri_contentScheme() throws {
        #expect(!WebEidUriUtil.isWebEidUri(try makeURL("content://some/path")))
    }

    @Test
    func isWebEidUri_fileScheme() throws {
        #expect(!WebEidUriUtil.isWebEidUri(try makeURL("file:///some/path")))
    }

    @Test
    func getOperation_appLinks_auth() throws {
        #expect(WebEidUriUtil.getOperation(from: try makeURL("https://id.eesti.ee/auth#dGVzdA")) == .auth)
    }

    @Test
    func getOperation_appLinks_cert() throws {
        #expect(WebEidUriUtil.getOperation(from: try makeURL("https://id.eesti.ee/cert#dGVzdA")) == .cert)
    }

    @Test
    func getOperation_appLinks_sign() throws {
        #expect(WebEidUriUtil.getOperation(from: try makeURL("https://id.eesti.ee/sign#dGVzdA")) == .sign)
    }

    @Test
    func getOperation_appLinks_unknownOperation_returnsNil() throws {
        #expect(WebEidUriUtil.getOperation(from: try makeURL("https://id.eesti.ee/unknown")) == .unknown)
    }

    @Test
    func getOperation_unrelatedUri_returnsNil() throws {
        #expect(WebEidUriUtil.getOperation(from: try makeURL("https://example.com/auth")) == .unknown)
    }

    @Test
    func isWebEidUri_customScheme_auth() throws {
        #expect(WebEidUriUtil.isWebEidUri(try makeURL("web-eid-mobile://auth")))
    }

    @Test
    func isWebEidUri_customScheme_cert() throws {
        #expect(WebEidUriUtil.isWebEidUri(try makeURL("web-eid-mobile://cert")))
    }

    @Test
    func isWebEidUri_customScheme_sign() throws {
        #expect(WebEidUriUtil.isWebEidUri(try makeURL("web-eid-mobile://sign")))
    }

    @Test
    func isWebEidUri_customScheme_unknownOperation() throws {
        #expect(!WebEidUriUtil.isWebEidUri(try makeURL("web-eid-mobile://unknown")))
    }

    @Test
    func getOperation_customScheme_auth() throws {
        #expect(WebEidUriUtil.getOperation(from: try makeURL("web-eid-mobile://auth#dGVzdA")) == .auth)
    }

    @Test
    func getOperation_customScheme_cert() throws {
        #expect(WebEidUriUtil.getOperation(from: try makeURL("web-eid-mobile://cert#dGVzdA")) == .cert)
    }

    @Test
    func getOperation_customScheme_sign() throws {
        #expect(WebEidUriUtil.getOperation(from: try makeURL("web-eid-mobile://sign#dGVzdA")) == .sign)
    }

    @Test
    func getOperation_unknownOperation_returnsNil() throws {
        #expect(WebEidUriUtil.getOperation(from: try makeURL("web-eid-mobile://unknown")) == .unknown)
    }

    // MARK: - displayOrigin

    @Test
    func displayOrigin_leavesAPlainASCIIOriginUnchanged() {
        #expect(WebEidUriUtil.displayOrigin("https://id.eesti.ee") == "https://id.eesti.ee")
        #expect(WebEidUriUtil.displayOrigin("https://id.eesti.ee:8443") == "https://id.eesti.ee:8443")
    }

    @Test
    func displayOrigin_doesNotLetABidiOverrideReorderTheHost() {
        let spoofed = "https://evil.com%E2%80%AEmoc.knab"

        let shown = WebEidUriUtil.displayOrigin(spoofed)

        #expect(shown == "https://evil.com%E2%80%AEmoc.knab")
        #expect(!shown.unicodeScalars.contains { $0.properties.isBidiControl })
    }

    @Test
    func displayOrigin_doesNotRenderAPunycodeHostAsItsUnicodeHomograph() {
        let shown = WebEidUriUtil.displayOrigin("https://xn--80ak6aa92e.com")

        #expect(shown != "https://аррӏе.com")
        #expect(shown.allSatisfy { $0.isASCII })
    }

    @Test
    func displayOrigin_keepsAnEncodedSlashEncoded() {
        #expect(WebEidUriUtil.displayOrigin("https://a%2Fb.com") == "https://a%2Fb.com")
    }

}
