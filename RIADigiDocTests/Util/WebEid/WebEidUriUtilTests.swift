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

    private func makeURL(_ string: String) -> URL {
        URL(string: string)!
    }

    @Test
    func isWebEidUri_appLinks_auth() {
        #expect(WebEidUriUtil.isWebEidUri(makeURL("https://riadigidoc.ee/auth")))
    }

    @Test
    func isWebEidUri_appLinks_cert() {
        #expect(WebEidUriUtil.isWebEidUri(makeURL("https://riadigidoc.ee/cert")))
    }

    @Test
    func isWebEidUri_appLinks_sign() {
        #expect(WebEidUriUtil.isWebEidUri(makeURL("https://riadigidoc.ee/sign")))
    }

    @Test
    func isWebEidUri_appLinks_unknownOperation() {
        #expect(!WebEidUriUtil.isWebEidUri(makeURL("https://riadigidoc.ee/unknown")))
    }

    @Test
    func isWebEidUri_wrongHost() {
        #expect(!WebEidUriUtil.isWebEidUri(makeURL("https://evil.com/auth")))
    }

    @Test
    func isWebEidUri_contentScheme() {
        #expect(!WebEidUriUtil.isWebEidUri(makeURL("content://some/path")))
    }

    @Test
    func isWebEidUri_fileScheme() {
        #expect(!WebEidUriUtil.isWebEidUri(makeURL("file:///some/path")))
    }

    @Test
    func getOperation_appLinks_auth() {
        #expect(WebEidUriUtil.getOperation(from: makeURL("https://riadigidoc.ee/auth#dGVzdA")) == .auth)
    }

    @Test
    func getOperation_appLinks_cert() {
        #expect(WebEidUriUtil.getOperation(from: makeURL("https://riadigidoc.ee/cert#dGVzdA")) == .cert)
    }

    @Test
    func getOperation_appLinks_sign() {
        #expect(WebEidUriUtil.getOperation(from: makeURL("https://riadigidoc.ee/sign#dGVzdA")) == .sign)
    }

    @Test
    func getOperation_appLinks_unknownOperation_returnsNil() {
        #expect(WebEidUriUtil.getOperation(from: makeURL("https://riadigidoc.ee/unknown")) == nil)
    }

    @Test
    func getOperation_unrelatedUri_returnsNil() {
        #expect(WebEidUriUtil.getOperation(from: makeURL("https://example.com/auth")) == nil)
    }

    @Test
    func isWebEidUri_customScheme_auth() {
        #expect(WebEidUriUtil.isWebEidUri(makeURL("web-eid-mobile://auth")))
    }

    @Test
    func isWebEidUri_customScheme_cert() {
        #expect(WebEidUriUtil.isWebEidUri(makeURL("web-eid-mobile://cert")))
    }

    @Test
    func isWebEidUri_customScheme_sign() {
        #expect(WebEidUriUtil.isWebEidUri(makeURL("web-eid-mobile://sign")))
    }

    @Test
    func isWebEidUri_customScheme_unknownOperation() {
        #expect(!WebEidUriUtil.isWebEidUri(makeURL("web-eid-mobile://unknown")))
    }

    @Test
    func getOperation_customScheme_auth() {
        #expect(WebEidUriUtil.getOperation(from: makeURL("web-eid-mobile://auth#dGVzdA")) == .auth)
    }

    @Test
    func getOperation_customScheme_cert() {
        #expect(WebEidUriUtil.getOperation(from: makeURL("web-eid-mobile://cert#dGVzdA")) == .cert)
    }

    @Test
    func getOperation_customScheme_sign() {
        #expect(WebEidUriUtil.getOperation(from: makeURL("web-eid-mobile://sign#dGVzdA")) == .sign)
    }

    @Test
    func getOperation_unknownOperation_returnsNil() {
        #expect(WebEidUriUtil.getOperation(from: makeURL("web-eid-mobile://unknown")) == nil)
    }
}
