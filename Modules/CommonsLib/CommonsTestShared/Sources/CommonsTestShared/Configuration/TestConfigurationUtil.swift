import Foundation

public struct TestConfigurationUtil {

    public init() {}

    public static func mockConfigurationResponse() -> String {
        // swiftlint:disable:next line_length
        return "{\"META-INF\":{\"URL\":\"https://test.abc\",\"DATE\":\"1970-01-01\",\"SERIAL\":1,\"VER\":1},\"SIVA-URL\":\"https://siva.someUrl.abc\",\"TSL-URL\":\"https://tsl.someUrl.abc\",\"TSL-CERTS\":[\"cert1\",\"cert2\"],\"TSA-URL\":\"https://tsa.someUrl.abc\",\"OCSP-URL-ISSUER\":{\"issuer1\":\"https://ocsp1.someUrl.abc\",\"issuer2\":\"https://ocsp2.someUrl.abc\"},\"LDAP-PERSON-URL\":\"https://ldap.person.someUrl.abc\",\"LDAP-CORP-URL\":\"https://ldap.corp.someUrl.abc\",\"MID-PROXY-URL\":\"https://mid.proxy.someUrl.abc\",\"MID-SK-URL\":\"https://mid.sk.someUrl.abc\",\"SIDV2-PROXY-URL\":\"https://sidv2.proxy.someUrl.abc\",\"SIDV2-SK-URL\":\"https://sidv2.sk.someUrl.abc\",\"CERT-BUNDLE\":[\"certBundle1\",\"certBundle2\"],\"LDAP-CERTS\":[\"ldapCert1\",\"ldapCert2\"],\"configurationLastUpdateCheckDate\":\"1970-01-01T00:00:00Z\",\"configurationUpdateDate\":\"1970-01-01T00:00:00Z\"}".trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
