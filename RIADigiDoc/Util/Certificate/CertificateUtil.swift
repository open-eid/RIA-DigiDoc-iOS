// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import CommonsLib
import Foundation
import SwiftASN1
import X509
import UtilsLib

public struct CertificateUtil: CertificateUtilProtocol, Loggable {
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
        guard let notValidAfterDate = getNotValidAfterDate(cert: cert) else { return "" }

        let dateTime = DateUtil.getFormattedDateTime(date: notValidAfterDate, isUTC: false)

        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        let certStart = calendar.startOfDay(for: notValidAfterDate)

        if certStart < todayStart {
            return "\(dateTime.date) (\(expiredLabel))"
        } else {
            return dateTime.date
        }
    }

    public func getNotValidAfterDate(cert: Data) -> Date? {
        do {
            let certificate = try Certificate(derEncoded: cert.map { $0 })
            return certificate.notValidAfter
        } catch {
            CertificateUtil.logger().error(
                "Unable to get not valid after date from certificate: \(String(reflecting: error))"
            )
            return nil
        }
    }

    public func getNotValidDate(_ certData: Data?) throws -> String? {
        guard let certData else { return nil }
        let certificate = self.certificate(from: certData)
        guard let certificate else { return nil }
        return try getNotValidDate(from: certificate)
    }

    private func getNotValidDate(from certificate: SecCertificate) throws -> String? {
        let certificate = try Certificate(certificate)
        let notValidAfter = certificate.notValidAfter
        return DateUtil.getFormattedDateTime(
            date: notValidAfter,
            isUTC: false
        ).date
    }
}
