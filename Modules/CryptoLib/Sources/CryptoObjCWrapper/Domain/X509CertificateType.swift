// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import ASN1Decoder

@objc public enum CertType: UInt, Sendable {
    case unknownType
    case iDCardType
    case digiIDType
    case eResidentType
    case mobileIDType
    case smartIDType
    case eSealType
    case passwordType
}

extension X509Certificate {
    public func certType() -> CertType {
        if let ext = extensionObject(oid: OID.certificatePolicies) as? X509Certificate.CertificatePoliciesExtension {
            for policy in ext.policies ?? [] {
                switch policy.oid {
                case let oid where oid.starts(with: "1.3.6.1.4.1.51361.1.1.3"),
                    let oid where oid.starts(with: "1.3.6.1.4.1.51361.1.1.4"),
                    let oid where oid.starts(with: "1.3.6.1.4.1.51361.2.1.6"),
                    let oid where oid.contains("1.3.6.1.4.1.51361.2.1.6"): // Test OID
                    return .digiIDType
                case let oid where oid.starts(with: "1.3.6.1.4.1.51361.1.1"),
                    let oid where oid.starts(with: "1.3.6.1.4.1.51361.1.2"), // Test OID
                    let oid where oid.starts(with: "1.3.6.1.4.1.51361.2.1"),
                    let oid where oid.contains("1.3.6.1.4.1.51361.2.1"), // Test OID
                    let oid where oid.starts(with: "1.3.6.1.4.1.51455.1.1"),
                    let oid where oid.starts(with: "1.3.6.1.4.1.51455.1.2"), // Test OID
                    let oid where oid.starts(with: "1.3.6.1.4.1.51455.2.1"),
                    let oid where oid.contains("1.3.6.1.4.1.51455.2.1"): // Test OID
                    return .iDCardType
                case let oid where oid.starts(with: "1.3.6.1.4.1.10015.1.3"),
                     let oid where oid.starts(with: "1.3.6.1.4.1.10015.11.1"):
                    return .mobileIDType
                case let oid where oid.starts(with: "1.3.6.1.4.1.10015.7.3"),
                     let oid where oid.starts(with: "1.3.6.1.4.1.10015.7.1"),
                     let oid where oid.starts(with: "1.3.6.1.4.1.10015.2.1"):
                    return .eSealType
                default:
                    break
                }
            }
        }
        return .unknownType
    }
}
