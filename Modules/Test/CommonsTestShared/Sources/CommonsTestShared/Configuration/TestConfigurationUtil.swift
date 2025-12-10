/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
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

public struct TestConfigurationUtil {

    public init() {}

    public static func mockConfigurationResponse() -> String {
        // swiftlint:disable:next line_length
        return "{\"META-INF\":{\"URL\":\"https://test.abc\",\"DATE\":\"1970-01-01\",\"SERIAL\":1,\"VER\":1},\"SIVA-URL\":\"https://siva.someUrl.abc\",\"TSL-URL\":\"https://tsl.someUrl.abc\",\"TSL-CERTS\":[\"Y2VydDE=\",\"Y2VydDI=\"],\"TSA-URL\":\"https://tsa.someUrl.abc\",\"OCSP-URL-ISSUER\":{\"issuer1\":\"https://ocsp1.someUrl.abc\",\"issuer2\":\"https://ocsp2.someUrl.abc\"},\"LDAP-PERSON-URL\":\"https://ldap.person.someUrl.abc\",\"LDAP-PERSON-URLS\":[\"https://ldap.person.someUrl.abc\", \"https://ldap.person.someUrl2.abc\"],\"LDAP-CORP-URL\":\"https://ldap.corp.someUrl.abc\",\"MID-PROXY-URL\":\"https://mid.proxy.someUrl.abc\",\"MID-SK-URL\":\"https://mid.sk.someUrl.abc\",\"SIDV2-PROXY-URL\":\"https://sidv2.proxy.someUrl.abc\",\"SIDV2-SK-URL\":\"https://sidv2.sk.someUrl.abc\",\"CERT-BUNDLE\":[\"Y2VydEJ1bmRsZTE=\",\"Y2VydEJ1bmRsZTI=\"],\"LDAP-CERTS\":[\"bGRhcENlcnQx\",\"bGRhcENlcnQy\"],\"configurationLastUpdateCheckDate\":\"1970-01-01T00:00:00Z\",\"configurationUpdateDate\":\"1970-01-01T00:00:00Z\",\"CDOC2-DEFAULT-KEYSERVER\":\"https://cdoc2DefaultKeyserver.someUrl.abc\",\"CDOC2-USE-KEYSERVER\":false,\"CDOC2-CONF\":{\"00000000-0000-0000-0000-000000000000\":{\"NAME\":\"RIA\",\"POST\":\"https://cdoc2.example.ee:8443\",\"FETCH\":\"https://cdoc2.example.ee:8444\"}}}".trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
