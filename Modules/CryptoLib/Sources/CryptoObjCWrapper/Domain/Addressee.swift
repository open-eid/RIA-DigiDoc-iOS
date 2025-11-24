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

    @objc public init(
        data: Data,
        cnVal: String,
        givenName: String?,
        surname: String?,
        serialNumber: String?,
        certType: CertType,
        validTo: Date?
    ) {
        self.identifier = cnVal
        self.data = data
        self.givenName = givenName
        self.surname = surname
        self.serialNumber = serialNumber
        self.certType = certType
        self.validTo = validTo
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

    public init(cert: Data, x509: X509Certificate?) {
        data = cert
        let cnVal = x509?.subject(oid: .commonName)?.joined(separator: ",") ?? ""
        let split = cnVal.split(separator: ",").map { String($0) }
        if split.count > 1 {
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
