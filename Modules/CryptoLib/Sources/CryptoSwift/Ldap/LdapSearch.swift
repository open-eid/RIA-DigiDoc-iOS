// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import CryptoObjCWrapper
import ASN1Decoder
import Foundation
import UtilsLib

final public class LdapSearch: LdapSearchProtocol, Loggable {
    private let ldapConfiguration: LdapConfigurationProtocol

    public init(
        ldapConfiguration: LdapConfigurationProtocol
    ) {
        self.ldapConfiguration = ldapConfiguration
    }

    enum KeyUsage: Int {
        case keyEncipherment = 2
        case keyAgreement = 4
    }

    enum SearchType {
        case personalCode(String)
        case registryCode(String)
        case other(String)

        init(from: String) {
            self = switch (from.allSatisfy({ $0.isNumber }), from.count) {
            case (true, 11): .personalCode(from)
            case (true, 8): .registryCode(from)
            default: .other(from)
            }
        }

        var filter: LdapFilter {
            switch self {
            case .registryCode(let code): .equals(attribute: "serialNumber", value: code)
            case .personalCode(let code): .equals(attribute: "serialNumber", value: "PNOEE-\(code)")
            case .other(let cnVal): .contains(attribute: "cn", value: cnVal)
            }
        }
    }

    @MainActor public func search(identityCode: String) async -> LdapSearchResult {
        let settings = await self.ldapConfiguration.settings()

        let searchType = SearchType(from: identityCode)
        let urls: [URL]
        if case .personalCode = searchType {
            LdapSearch.logger().info("Searching with personal code from LDAP")
            urls = settings.personURLs
        } else {
            LdapSearch.logger().info("Searching with corporation keyword from LDAP")
            urls = settings.corpURL.map { [$0] } ?? []
        }

        var result = LdapSearchResult(addressees: [], tooManyResults: false)
        for url in urls {
            let endpointResult = await LdapSearch.search(
                searchType: searchType,
                url: url,
                caCertificates: settings.caCertificates
            )
            result.addressees += endpointResult.addressees
            result.tooManyResults = result.tooManyResults || endpointResult.tooManyResults
            result.isNetworkError = result.isNetworkError || endpointResult.isNetworkError
        }
        return result
    }

    static private func search(
        searchType: SearchType,
        url: URL,
        caCertificates: [Data]
    ) async -> LdapSearchResult {
        LdapSearch.logger().info("Searching from LDAP. Url: \(url) \(searchType.filter)")
        do {
            let response = try await LdapRequest(
                url: url,
                filter: searchType.filter,
                caCertificates: caCertificates
            ).run()
            let addressees = addressees(certificates: response.certificates)
            LdapSearch.logger().info("Result (\(addressees.count)) from \(response.entryCount) entries")
            return LdapSearchResult(
                addressees: addressees,
                tooManyResults: response.entryCount >= Int(LdapMessage.sizeLimit)
            )
        } catch let error as LdapError {
            LdapSearch.logger().info("LDAP search failed: \(String(describing: error))")
            return LdapSearchResult(addressees: [], tooManyResults: false, isNetworkError: error.isNetworkError)
        } catch {
            LdapSearch.logger().info("LDAP search failed: \(error.localizedDescription)")
            return LdapSearchResult(addressees: [], tooManyResults: false)
        }
    }

    static private func addressees(certificates: [Data]) -> [Addressee] {
        var result = [Addressee]()
        for data in certificates {
            guard !Task.isCancelled else { break }
            guard let x509 = try? X509Certificate(der: data) else {
                continue
            }
            let type = x509.certType()
            let keyUsage = x509.keyUsage // Empty without the extension
            let canEncrypt = [KeyUsage.keyEncipherment, .keyAgreement].contains {
                keyUsage.indices.contains($0.rawValue) && keyUsage[$0.rawValue]
            }
            if canEncrypt,
               !x509.extendedKeyUsage.contains(OID.serverAuth.rawValue),
               type != .eSealType || !x509.extendedKeyUsage.contains(OID.clientAuth.rawValue),
               type != .mobileIDType && type != .unknownType {
                result.append(Addressee(cert: data, x509: x509))
            }
        }
        return result
    }
}
