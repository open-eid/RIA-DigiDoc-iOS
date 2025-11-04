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

import LDAP
import OSLog
import ASN1Decoder
import Foundation

public class OpenLdap {
    private static let logger = Logger(
        subsystem: "ee.ria.digidoc.RIADigiDoc",
        category: "OpenLdap"
    )

    private let ldapConfiguration: LdapConfiguration

    public init(
        moppLdapConfiguration: LdapConfiguration
    ) {
        self.ldapConfiguration = moppLdapConfiguration
    }

    typealias LDAP = OpaquePointer
    typealias LDAPMessage = OpaquePointer
    typealias BerElement = OpaquePointer

    enum KeyUsage: Int {
        case digitalSignature = 0
        case nonRepudiation = 1
        case keyEncipherment = 2
        case dataEncipherment = 3
        case keyAgreement = 4
        case keyCertSign = 5
        case cRLSign = 6
        case encipherOnly = 7
        case decipherOnly = 8
    }

    enum SearchType {
        case personalCode
        case registryCode
        case other

        init(identityCode: String) {
            self = switch (identityCode.allSatisfy({ $0.isNumber }), identityCode.count) {
            case (true, 11): .personalCode
            case (true, 8): .registryCode
            default: .other
            }
        }
    }

    @MainActor public func search(identityCode: String) -> (
        addressees: [Addressee],
        tooManyResults: Bool
    ) {
        var filePath: String?
        if let ldapCertFilePath = self.ldapConfiguration.ldapCertsPath {
            if FileManager.default.fileExists(atPath: ldapCertFilePath) {
                filePath = ldapCertFilePath
            } else {
                OpenLdap.logger.error("File ldapCerts.pem does not exist at directory path: \(ldapCertFilePath)")
                filePath = nil
            }
        }

        if SearchType(identityCode: identityCode) == SearchType.personalCode {
            OpenLdap.logger.debug("Searching with personal code from LDAP")
            var result = [Addressee]()
            var tooManyResults = false
            for url in LdapConfiguration.ldapPersonURLS {
                if let ldapPersonUrl = url {
                    let (addresses, found) = OpenLdap.search(
                        identityCode: identityCode,
                        url: ldapPersonUrl,
                        certificatePath: filePath
                    )
                    result.append(contentsOf: addresses)
                    if found >= 50 {
                        tooManyResults = true
                    }
                }
            }
            return (result, tooManyResults)
        } else {
            if let ldapCorpURL = LdapConfiguration.ldapCorpURL {
                OpenLdap.logger.debug("Searching with corporation keyword from LDAP")
                let (addresses, found) = OpenLdap.search(
                    identityCode: identityCode,
                    url: ldapCorpURL,
                    certificatePath: filePath
                )
                return (addresses, found >= 50)
            } else {
                return ([], false)
            }
        }
    }

    static private func search(identityCode: String, url: URL, certificatePath: String?) -> (
        addressees: [Addressee],
        totalAddressees: Int
    ) {
        if !configureTLSIfNeeded(url, certificatePath) {
            return ([], 0)
        }

        var ldap: LDAP?
        let host: String = getLDAPHostUrlString(from: url)
        var ldapReturnCode: Int32 = -1
        var ldapVersion: Int32 = -1
        ldap = initializeLDAPConnection(&ldapReturnCode, &ldapVersion, &ldap, host)
        if ldap == nil {
            return ([], 0)
        }
        let filter: String = getFilter(identityCode: identityCode)

        var msgId: Int32 = 0
        OpenLdap.logger.debug("Searching from LDAP. Url: \(url) \(filter)")
        var attr = Array("userCertificate;binary".utf8CString)
        let distinguishedName = getDistinguishedName(from: url)
        ldapReturnCode = getLdapReturnCode(&attr, ldap, distinguishedName, filter, &msgId)

        guard ldapReturnCode == LDAP_SUCCESS else {
            OpenLdap.logger.error("ldap_search_ext failed: \(String(cString: ldap_err2string(ldapReturnCode)))")
            return ([], 0)
        }

        var result = [Addressee]()
        var totalAddressees = 0
        var msg: LDAPMessage?
        while !Task.isCancelled {
            var timeValue = timeval(tv_sec: 0, tv_usec: 100_000)
            ldapReturnCode = ldap_result(ldap, msgId, LDAP_MSG_ONE, &timeValue, &msg)

            defer {
                if let msg = msg { ldap_msgfree(msg) }
            }
            switch ldapReturnCode {
            case Int32(LDAP_RES_SEARCH_ENTRY):
                let addressees = attributes(ldap: ldap, msg: msg)
                result.append(contentsOf: addressees)
                totalAddressees += 1
            case Int32(LDAP_RES_SEARCH_RESULT):
                return (addressees: result, totalAddressees: totalAddressees)
            case Int32(LDAP_SUCCESS):
                break
            default:
                OpenLdap.logger.error("ldap_result failed: \(String(cString: ldap_err2string(ldapReturnCode)))")
                return (addressees: result, totalAddressees: totalAddressees)
            }
        }

        ldap_abandon_ext(ldap, msgId, nil, nil)

        return (addressees: result, totalAddressees: totalAddressees)
    }

    static private func getLdapReturnCode(
        _ attr: inout [Int8],
        _ ldap: OpenLdap.LDAP?,
        _ distinguishedName: String,
        _ filter: String,
        _ msgId: inout Int32
    ) -> Int32 {
        return attr.withUnsafeMutableBufferPointer { attr in var attrs = [attr.baseAddress, nil]
            return attrs
                .withUnsafeMutableBufferPointer { attrs in
                    ldap_search_ext(
                        ldap,
                        distinguishedName,
                        LDAP_SCOPE_SUBTREE,
                        filter,
                        attrs.baseAddress,
                        0,
                        nil,
                        nil,
                        nil,
                        0,
                        &msgId
                    )
                }
        }
    }

    static private func configureTLSIfNeeded(_ url: URL, _ certificatePath: String?) -> Bool {
        if url.scheme?.lowercased() == "ldaps" {
            guard configureTLS(url: url, certificatePath: certificatePath) else { return false }
        }

        return true
    }

    static private func initializeLDAPConnection(
        _ ldapReturnCode: inout Int32,
        _ ldapVersion: inout Int32,
        _ ldap: inout OpaquePointer?,
        _ host: String
    ) -> LDAP? {
        ldapReturnCode = ldap_initialize(&ldap, host)
        defer {
            if let ldap = ldap { ldap_destroy(ldap) }
        }

        guard ldapReturnCode == LDAP_SUCCESS else {
            let returnCode = ldapReturnCode
            OpenLdap.logger.error("Failed to initialize LDAP: \(String(cString: ldap_err2string(returnCode)))")
            return nil
        }

        ldapVersion = LDAP_VERSION3
        ldapReturnCode = ldap_set_option(
            ldap,
            LDAP_OPT_PROTOCOL_VERSION,
            &ldapVersion
        )
        guard ldapReturnCode == LDAP_SUCCESS else {
            let returnCode = ldapReturnCode
            OpenLdap.logger.error(
                "ldap_set_option(PROTOCOL_VERSION) failed: \(String(cString: ldap_err2string(returnCode)))"
            )
            return nil
        }

        return ldap
    }

    static private func configureTLS(url _: URL, certificatePath: String?) -> Bool {
        if let certificatePath = certificatePath, !certificatePath.isEmpty {
            guard setLdapOption(option: LDAP_OPT_X_TLS_CACERTFILE, value: certificatePath) else { return false }
        } else {
            guard let bundlePath = Bundle(for: OpenLdap.self).resourcePath else { return false }
            guard setLdapOption(option: LDAP_OPT_X_TLS_CACERTDIR, value: bundlePath) else { return false }
        }
        var ldapConnectionReset = 0
        let result = ldap_set_option(nil, LDAP_OPT_X_TLS_NEWCTX, &ldapConnectionReset)
        guard result == LDAP_SUCCESS else {
            OpenLdap.logger.error(
                "ldap_set_option(LDAP_OPT_X_TLS_NEWCTX) failed: \(String(cString: ldap_err2string(result)))"
            )
            return false
        }
        return true
    }

    static private func getLDAPHostUrlString(from url: URL) -> String {
        if var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            components.path = ""
            components.query = nil
            components.fragment = nil
            return components.string ?? url.absoluteString
        } else {
            return url.absoluteString
        }
    }

    static private func getFilter(identityCode: String) -> String {
        let escapedIdentityCode = getEscapedIdentityCode(identityCode: identityCode)
        let type = SearchType(identityCode: escapedIdentityCode)

        switch type {
        case .registryCode:
            return "(serialNumber=\(escapedIdentityCode))"
        case .personalCode:
            return "(serialNumber=PNOEE-\(escapedIdentityCode))"
        case .other:
            return "(cn=*\(escapedIdentityCode)*)"
        }
    }

    static private func getEscapedIdentityCode(identityCode: String) -> String {
        return identityCode
            .replacingOccurrences(
                of: "\\",
                with: "\\\\"
            )
            .replacingOccurrences(
                of: "(",
                with: "\\("
            )
            .replacingOccurrences(
                of: ")",
                with: "\\)"
            )
            .replacingOccurrences(
                of: "*",
                with: "\\*"
            )
    }

    static private func getDistinguishedName(from url: URL) -> String {
        var distinguishedName = url.path
        if distinguishedName.isEmpty {
            distinguishedName = "c=EE"
        } else {
            distinguishedName.remove(at: distinguishedName.startIndex)
        }
        return distinguishedName
    }

    static private func setLdapOption(option: Int32, value: String) -> Bool {
        let result = ldap_set_option(
            nil,
            option,
            value
        )
        if result != LDAP_SUCCESS {
            OpenLdap.logger.error("ldap_set_option failed: \(String(cString: ldap_err2string(result)))")
            return false
        }
        return true
    }

    static private func attributes(ldap: LDAP?, msg: LDAPMessage?) -> [Addressee] {
        var result = [Addressee]()
        var message = ldap_first_message(ldap, msg)
        while let currentMessage = message {
            guard !Task.isCancelled else { break }
            if ldap_msgtype(currentMessage) == LDAP_RES_SEARCH_ENTRY {
                var ber: BerElement?
                var attrPointer = ldap_first_attribute(ldap, currentMessage, &ber)
                defer {
                    if let ber = ber { ber_free(ber, 0) }
                }
                while let attr = attrPointer {
                    defer { ldap_memfree(attr) }
                    result.append(
                        contentsOf: values(
                            ldap: ldap,
                            msg: currentMessage,
                            tag: String(cString: attr)
                        )
                    )
                    attrPointer = ldap_next_attribute(ldap, currentMessage, ber)
                }

                if let namePointer = ldap_get_dn(ldap, currentMessage) {
                    OpenLdap.logger.debug("Result (\(result.count)) \(String(cString: namePointer))")
                    ldap_memfree(namePointer)
                }
            }
            message = ldap_next_message(ldap, currentMessage)
        }
        return result
    }

    static private func values(ldap: LDAP?, msg: LDAPMessage, tag: String) -> [Addressee] {
        var result = [Addressee]()
        guard let bvals = ldap_get_values_len(ldap, msg, tag) else {
            return result
        }
        defer { ldap_value_free_len(bvals) }

        var index = 0
        while let bval = bvals[index] {
            guard !Task.isCancelled else { break }
            let data = Data(bytes: bval.pointee.bv_val, count: Int(bval.pointee.bv_len))
            index += 1
            guard let x509 = try? X509Certificate(der: data) else {
                continue
            }
            let type = x509.certType()
            if x509.keyUsage[KeyUsage.keyEncipherment.rawValue] || x509.keyUsage[KeyUsage.keyAgreement.rawValue],
               !x509.extendedKeyUsage.contains(OID.serverAuth.rawValue),
               type != .eSealType || !x509.extendedKeyUsage.contains(OID.clientAuth.rawValue),
               type != .mobileIDType && type != .unknownType {
                result.append(Addressee(cert: data, x509: x509))
            }
        }
        return result
    }
}
