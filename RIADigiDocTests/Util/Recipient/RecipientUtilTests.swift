/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
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

import CryptoObjCWrapper
import Foundation
import Testing

@MainActor
final class RecipientUtilTests {

    private let recipientUtil: RecipientUtilProtocol

    init() async throws {
        recipientUtil = RecipientUtil()
    }

    private func recipient(
        certificate: String,
        cnVal: String = "SURNAME,GIVENNAME,38001085718"
    ) -> Addressee {
        Addressee(
            data: Data(certificate.utf8),
            cnVal: cnVal,
            givenName: "GIVENNAME",
            surname: "SURNAME",
            serialNumber: "38001085718",
            certType: .iDCardType,
            validTo: Date.distantFuture
        )
    }

    @Test
    func isRecipientAdded_returnsTrueWhenCertificateBytesMatch() {
        let added = [recipient(certificate: "cert-a"), recipient(certificate: "cert-b")]

        let result = recipientUtil.isRecipientAdded(recipient(certificate: "cert-b"), in: added)

        #expect(result)
    }

    @Test
    func isRecipientAdded_returnsFalseWhenNoCertificateBytesMatch() {
        let added = [recipient(certificate: "cert-a"), recipient(certificate: "cert-b")]

        let result = recipientUtil.isRecipientAdded(recipient(certificate: "cert-c"), in: added)

        #expect(!result)
    }

    @Test
    func isRecipientAdded_returnsFalseWhenNoRecipientsAdded() {
        let result = recipientUtil.isRecipientAdded(recipient(certificate: "cert-a"), in: [])

        #expect(!result)
    }

    @Test
    func isRecipientAdded_returnsFalseForSamePersonWithDifferentCertificate() {
        let added = [recipient(certificate: "old-cert", cnVal: "SURNAME,GIVENNAME,38001085718")]

        let result = recipientUtil.isRecipientAdded(
            recipient(certificate: "renewed-cert", cnVal: "SURNAME,GIVENNAME,38001085718"),
            in: added
        )

        #expect(!result)
    }

    @Test
    func isRecipientAdded_returnsTrueForDifferentPeopleSharingCertificateBytes() {
        let added = [recipient(certificate: "cert-a", cnVal: "OTHER,PERSON,60001019906")]

        let result = recipientUtil.isRecipientAdded(
            recipient(certificate: "cert-a", cnVal: "SURNAME,GIVENNAME,38001085718"),
            in: added
        )

        #expect(result)
    }
}
