import Foundation
import OSLog
import SwiftASN1
import X509
import UtilsLib

public class CertificateUtil {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "CertificateUtil")

    public static func pemToDerData(fromPEM pem: Data) -> Data? {
        guard let pemString = String(data: pem, encoding: .utf8) else { return nil }
        let lines = pemString.components(separatedBy: .newlines)
        let base64Lines = lines.filter { !$0.hasPrefix("---") && !$0.isEmpty }
        let base64String = base64Lines.joined()
        if base64String.isEmpty { return nil }
        return Data(base64Encoded: base64String)
    }

    public static func getSubjectAttribute(cert: Data, attribute: ASN1ObjectIdentifier) -> String {
        do {
            let certificate = try Certificate(derEncoded: cert.map { $0 })

            return String(describing: certificate.subject
                            .flatMap { $0 }
                            .first { $0.type == attribute }?.value ?? RelativeDistinguishedName.Attribute
                            .Value(utf8String: ""))
        } catch {
            CertificateUtil.logger.error(
                "Unable to get issuer attribute \(attribute) from certificate: \(error.localizedDescription)"
            )
            return ""
        }
    }

    public static func getNotValidAfterWithExpiredLabel(cert: Data, expiredLabel: String) -> String {
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
            CertificateUtil.logger.error(
                "Unable to get not valid after from certificate: \(error.localizedDescription)"
            )
            return ""
        }
    }

}
