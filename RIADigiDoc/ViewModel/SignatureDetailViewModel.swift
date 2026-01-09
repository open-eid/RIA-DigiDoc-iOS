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

import UtilsLib
import Foundation
import X509

@Observable
@MainActor
class SignatureDetailViewModel: SignatureDetailViewModelProtocol, Loggable {

    func getIssuerName(cert: Data) -> String {
        do {
            let certificate = try Certificate(derEncoded: cert.map { $0 })

            return String(
                describing: certificate.issuer
                    .flatMap { $0 }
                    .first { $0.type == .RDNAttributeType.commonName }?.value ??
                    RelativeDistinguishedName.Attribute.Value(utf8String: ""))
        } catch {
            SignatureDetailViewModel.logger()
                .error("Unable to get issuer CommonName from certificate: \(error.localizedDescription)")
            return ""
        }
    }

    func getSubjectName(cert: Data) -> String {
        do {
            let certificate = try Certificate(derEncoded: cert.map { $0 })

            return String(
                describing: certificate.subject
                    .flatMap { $0 }
                    .first { $0.type == .RDNAttributeType.commonName }?.value ??
                    RelativeDistinguishedName.Attribute.Value(utf8String: ""))
        } catch {
            SignatureDetailViewModel.logger()
                .error("Unable to get subject CommonName from certificate: \(error.localizedDescription)")
            return ""
        }
    }
}
