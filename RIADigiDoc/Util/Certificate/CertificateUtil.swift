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

import CommonsLib
import Foundation
import SwiftASN1
import X509
import UtilsLib

public struct CertificateUtil: CertificateUtilProtocol, Loggable {
    public init() {}

    public func pemToDerData(fromPEM pem: Data) -> Data? {
        guard let pemString = String(data: pem, encoding: .utf8) else { return nil }
        let lines = pemString.components(separatedBy: .newlines)
        let base64Lines = lines.filter { !$0.hasPrefix("---") && !$0.isEmpty }
        let base64String = base64Lines.joined()
        if base64String.isEmpty { return nil }
        return Data(base64Encoded: base64String)
    }

    public func certificate(from data: Data) -> SecCertificate? {
        return SecCertificateCreateWithData(nil, data as CFData)
    }

    public func getSubjectAttribute(cert: Data, attribute: ASN1ObjectIdentifier) -> String {
        do {
            let certificate = try Certificate(derEncoded: cert.map { $0 })

            return String(describing: certificate.subject
                            .flatMap { $0 }
                            .first { $0.type == attribute }?.value ?? RelativeDistinguishedName.Attribute
                            .Value(utf8String: ""))
        } catch {
            CertificateUtil.logger().error(
                "Unable to get subject attribute from certificate: \(String(reflecting: error))"
            )
            return ""
        }
    }

    public func getNotValidAfterWithExpiredLabel(cert: Data, expiredLabel: String) -> String {
        do {
            let certificate = try Certificate(derEncoded: cert.map { $0 })
            let notValidAfterDate = certificate.notValidAfter

            let dateTime = DateUtil.getFormattedDateTime(
                date: notValidAfterDate,
                isUTC: false
            )

            let calendar = Calendar.current
            let todayStart = calendar.startOfDay(for: Date())
            let certStart = calendar.startOfDay(for: notValidAfterDate)

            if certStart < todayStart {
                return "\(dateTime.date) (\(expiredLabel))"
            } else {
                return dateTime.date
            }
        } catch {
            CertificateUtil.logger().error(
                "Unable to get not valid after from certificate: \(String(reflecting: error))"
            )
            return ""
        }
    }

}
