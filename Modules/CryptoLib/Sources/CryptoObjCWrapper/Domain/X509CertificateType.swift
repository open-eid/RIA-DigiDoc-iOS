import ASN1Decoder

@objc public enum CertType: UInt {
    case UnknownType
    case IDCardType
    case DigiIDType
    case EResidentType
    case MobileIDType
    case SmartIDType
    case ESealType
}

extension X509Certificate {
    public func certType() -> CertType {
        if let ext = extensionObject(oid: OID.certificatePolicies) as? X509Certificate.CertificatePoliciesExtension {
            for policy in ext.policies ?? [] {
                switch policy.oid {
                case let oid where oid.starts(with: "1.3.6.1.4.1.10015.1.1"),
                     let oid where oid.starts(with: "1.3.6.1.4.1.51361.1.1.1"):
                    return .IDCardType
                case let oid where oid.starts(with: "1.3.6.1.4.1.10015.1.2"),
                     let oid where oid.starts(with: "1.3.6.1.4.1.51361.1.1"),
                     let oid where oid.starts(with: "1.3.6.1.4.1.51455.1.1"):
                    return .DigiIDType
                case let oid where oid.starts(with: "1.3.6.1.4.1.10015.1.3"),
                     let oid where oid.starts(with: "1.3.6.1.4.1.10015.11.1"):
                    return .MobileIDType
                case let oid where oid.starts(with: "1.3.6.1.4.1.10015.7.3"),
                     let oid where oid.starts(with: "1.3.6.1.4.1.10015.7.1"),
                     let oid where oid.starts(with: "1.3.6.1.4.1.10015.2.1"):
                    return .ESealType
                default:
                    break
                }
            }
        }
        return .UnknownType
    }
}
