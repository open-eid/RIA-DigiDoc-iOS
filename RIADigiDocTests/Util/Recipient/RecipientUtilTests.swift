// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import CryptoObjCWrapper
import Foundation
import Testing

@MainActor
struct RecipientUtilTests {

    private let recipientUtil: RecipientUtilProtocol

    init() {
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
    func isRecipientAdded_trueWhenCertificateBytesMatch() {
        let added = [recipient(certificate: "cert-a"), recipient(certificate: "cert-b")]

        #expect(recipientUtil.isRecipientAdded(recipient(certificate: "cert-b"), in: added))
    }

    @Test
    func isRecipientAdded_falseWhenNoCertificateBytesMatch() {
        let added = [recipient(certificate: "cert-a"), recipient(certificate: "cert-b")]

        #expect(!recipientUtil.isRecipientAdded(recipient(certificate: "cert-c"), in: added))
    }

    @Test
    func isRecipientAdded_falseWhenNothingHasBeenAdded() {
        #expect(!recipientUtil.isRecipientAdded(recipient(certificate: "cert-a"), in: []))
    }

    @Test
    func isRecipientAdded_falseForSamePersonHoldingARenewedCertificate() {
        let added = [recipient(certificate: "old-cert", cnVal: "SURNAME,GIVENNAME,38001085718")]

        let renewed = recipient(certificate: "renewed-cert", cnVal: "SURNAME,GIVENNAME,38001085718")

        #expect(!recipientUtil.isRecipientAdded(renewed, in: added))
    }

    @Test
    func isRecipientAdded_trueForDifferentPeopleSharingCertificateBytes() {
        let added = [recipient(certificate: "cert-a", cnVal: "OTHER,PERSON,60001019906")]

        let other = recipient(certificate: "cert-a", cnVal: "SURNAME,GIVENNAME,38001085718")

        #expect(recipientUtil.isRecipientAdded(other, in: added))
    }

    @Test
    func isRecipientAdded_trueWhenEveryAddresseeHasEmptyCertificateBytes() {
        let passwordLock = recipient(certificate: "", cnVal: "")

        #expect(recipientUtil.isRecipientAdded(passwordLock, in: [recipient(certificate: "")]))
    }
}
