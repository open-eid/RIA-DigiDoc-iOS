// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import ASN1Decoder
import Foundation

@objc public final class Addressee: NSObject, Sendable {
    @objc public let data: Data
    public let identifier: String
    public let givenName: String?
    public let surname: String?
    public let serialNumber: String?
    public let certType: CertType
    public let validTo: Date?
    @MainActor
    @objc public var concatKDFAlgorithmURI: String
    @objc public let lockLabel: String
    @objc public let lockType: String

    @objc public init(
        data: Data,
        cnVal: String,
        givenName: String?,
        surname: String?,
        serialNumber: String?,
        certType: CertType,
        validTo: Date?,
        concatKDFAlgorithmURI: String = "",
        lockLabel: String = "",
        lockType: String = ""
    ) {
        self.identifier = cnVal
        self.data = data
        self.givenName = givenName
        self.surname = surname
        self.serialNumber = serialNumber
        self.certType = certType
        self.validTo = validTo
        self.concatKDFAlgorithmURI = concatKDFAlgorithmURI
        self.lockLabel = lockLabel
        self.lockType = lockType
    }

    @objc public convenience init(data: Data, cnVal: String) {
        self.init(
            data: data,
            cnVal: cnVal,
            givenName: nil,
            surname: nil,
            serialNumber: nil,
            certType: .unknownType,
            validTo: nil
        )
    }

    @objc public init(
        cnVal: String,
        serialNumber: String?,
        certType: CertType,
        validTo: Date?,
        data: Data,
        concatKDFAlgorithmURI: String = "",
        lockLabel: String = "",
        lockType: String = ""
    ) {
        let split = cnVal.split(separator: ",").map { String($0) }
        if split.count >= 3 {
            surname = split[0]
            givenName = split[1]
            identifier = split[2]
        } else {
            surname = nil
            givenName = nil
            identifier = cnVal
        }
        self.serialNumber = serialNumber
        self.certType = certType
        self.validTo = validTo
        self.data = data
        self.concatKDFAlgorithmURI = concatKDFAlgorithmURI
        self.lockLabel = lockLabel
        self.lockType = lockType
    }

    public init(cert: Data, x509: X509Certificate?) {
        data = cert
        let cnVal = x509?.subject(oid: .commonName)?.joined(separator: ",") ?? ""
        let split = cnVal.split(separator: ",").map { String($0) }
        if split.count >= 3 {
            surname = split[0]
            givenName = split[1]
            identifier = split[2]
        } else {
            surname = nil
            givenName = nil
            identifier = cnVal
        }
        serialNumber = x509?.subject(oid: .serialNumber)?.joined(separator: ",")
        certType = x509?.certType() ?? .unknownType
        validTo = x509?.notAfter
        concatKDFAlgorithmURI = ""
        lockLabel = ""
        lockType = ""
    }

    convenience public init(cert: Data) {
        self.init(cert: cert, x509: try? X509Certificate(der: cert))
    }
    // swiftlint:disable nsobject_prefer_isequal
    // MARK: - Equatable
    public static func == (lhs: Addressee, rhs: Addressee) -> Bool {
        return
            lhs.data == rhs.data &&
            lhs.identifier == rhs.identifier &&
            lhs.givenName == rhs.givenName &&
            lhs.surname == rhs.surname &&
            lhs.certType == rhs.certType &&
            lhs.validTo == rhs.validTo
    }

    static public func == (lhs: Addressee, rhs: Data) -> Bool {
        if lhs.data == rhs {
            return true
        }
        if let key = try? X509Certificate(der: rhs).publicKey?.derEncodedKey,
           lhs.data == key {
            return true
        }
        return false
    }
    // swiftlint:enable nsobject_prefer_isequal
}
