// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import Testing

struct RecipientDecryptionStatusTests {

    private let now = Date(timeIntervalSince1970: 1_800_000_000)
    private var future: Date { now.addingTimeInterval(60) }
    private var past: Date { now.addingTimeInterval(-60) }

    @Test
    func resolve_returnsNilForCDOC1ContainerEvenWithAValidToDate() {
        let status = RecipientDecryptionStatus.resolve(
            validTo: future,
            isCDOC2Container: false,
            isEncryptedOrDecrypted: true,
            now: now
        )

        #expect(status == nil)
    }

    @Test
    func resolve_returnsNilWhenThereIsNoValidToDate() {
        let status = RecipientDecryptionStatus.resolve(
            validTo: nil,
            isCDOC2Container: true,
            isEncryptedOrDecrypted: true,
            now: now
        )

        #expect(status == nil)
    }

    @Test
    func resolve_returnsNotEncryptedBeforeEncryptionWhenNotYetExpired() {
        let status = RecipientDecryptionStatus.resolve(
            validTo: future,
            isCDOC2Container: true,
            isEncryptedOrDecrypted: false,
            now: now
        )

        #expect(status == .notEncrypted)
    }

    @Test
    func resolve_returnsNotEncryptedExpiredBeforeEncryptionWhenAlreadyExpired() {
        let status = RecipientDecryptionStatus.resolve(
            validTo: past,
            isCDOC2Container: true,
            isEncryptedOrDecrypted: false,
            now: now
        )

        #expect(status == .notEncryptedExpired)
    }

    @Test
    func resolve_returnsValidAfterEncryptionWhenNotYetExpired() {
        let status = RecipientDecryptionStatus.resolve(
            validTo: future,
            isCDOC2Container: true,
            isEncryptedOrDecrypted: true,
            now: now
        )

        #expect(status == .valid)
    }

    @Test
    func resolve_returnsExpiredAfterEncryptionWhenAlreadyExpired() {
        let status = RecipientDecryptionStatus.resolve(
            validTo: past,
            isCDOC2Container: true,
            isEncryptedOrDecrypted: true,
            now: now
        )

        #expect(status == .expired)
    }

    @Test
    func resolve_treatsAnExpiryExactlyAtNowAsStillValid() {
        let status = RecipientDecryptionStatus.resolve(
            validTo: now,
            isCDOC2Container: true,
            isEncryptedOrDecrypted: true,
            now: now
        )

        #expect(status == .valid)
    }

    @Test
    func allExpiredDate_returnsTheLatestExpiryWhenEveryRecipientIsExpired() {
        let expiry = RecipientDecryptionStatus.allExpiredDate(
            validTos: [past, past.addingTimeInterval(-60)],
            isCDOC2Container: true,
            now: now
        )

        #expect(expiry == past)
    }

    @Test
    func allExpiredDate_returnsNilWhenOneRecipientIsStillValid() {
        let expiry = RecipientDecryptionStatus.allExpiredDate(
            validTos: [past, future],
            isCDOC2Container: true,
            now: now
        )

        #expect(expiry == nil)
    }

    @Test
    func allExpiredDate_returnsNilWhenARecipientHasNoExpiry() {
        let expiry = RecipientDecryptionStatus.allExpiredDate(
            validTos: [past, nil],
            isCDOC2Container: true,
            now: now
        )

        #expect(expiry == nil)
    }

    @Test
    func allExpiredDate_returnsNilForCDOC1Container() {
        let expiry = RecipientDecryptionStatus.allExpiredDate(
            validTos: [past],
            isCDOC2Container: false,
            now: now
        )

        #expect(expiry == nil)
    }

    @Test
    func allExpiredDate_returnsNilWhenThereAreNoRecipients() {
        let expiry = RecipientDecryptionStatus.allExpiredDate(
            validTos: [],
            isCDOC2Container: true,
            now: now
        )

        #expect(expiry == nil)
    }

    @Test
    func allExpiredDate_treatsAnExpiryExactlyAtNowAsStillValid() {
        let expiry = RecipientDecryptionStatus.allExpiredDate(
            validTos: [now],
            isCDOC2Container: true,
            now: now
        )

        #expect(expiry == nil)
    }

    @Test
    func allExpiredDate_treatsAZeroServerExpiryAsExpired() {
        let zeroExpiry = Date(timeIntervalSince1970: 0)

        let expiry = RecipientDecryptionStatus.allExpiredDate(
            validTos: [zeroExpiry],
            isCDOC2Container: true,
            now: now
        )

        #expect(expiry == zeroExpiry)
    }

    @Test
    func resolve_returnsExpiredWithoutDateForAZeroServerExpiry() {
        let status = RecipientDecryptionStatus.resolve(
            validTo: Date(timeIntervalSince1970: 0),
            isCDOC2Container: true,
            isEncryptedOrDecrypted: true,
            now: now
        )

        #expect(status == .expiredWithoutDate)
    }

    @Test
    func resolve_returnsExpiredWithoutDateForAZeroServerExpiryBeforeEncryption() {
        let status = RecipientDecryptionStatus.resolve(
            validTo: Date(timeIntervalSince1970: 0),
            isCDOC2Container: true,
            isEncryptedOrDecrypted: false,
            now: now
        )

        #expect(status == .expiredWithoutDate)
    }

    @Test
    func resolve_keepsTheDatedExpiredStatusForAnyRealPastDate() {
        let status = RecipientDecryptionStatus.resolve(
            validTo: Date(timeIntervalSince1970: 1),
            isCDOC2Container: true,
            isEncryptedOrDecrypted: true,
            now: now
        )

        #expect(status == .expired)
    }

    @Test
    func localizationKey_mapsEachStatusToItsOwnKey() {
        #expect(RecipientDecryptionStatus.notEncrypted.localizationKey == "Expires on")
        #expect(RecipientDecryptionStatus.notEncryptedExpired.localizationKey == "Expired on")
        #expect(RecipientDecryptionStatus.valid.localizationKey == "Decryption until")
        #expect(RecipientDecryptionStatus.expired.localizationKey == "Decryption expired")
        #expect(RecipientDecryptionStatus.expiredWithoutDate.localizationKey == "Decryption expired without date")
    }
}
