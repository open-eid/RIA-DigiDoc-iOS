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
    func localizationKey_mapsEachStatusToItsOwnKey() {
        #expect(RecipientDecryptionStatus.notEncrypted.localizationKey == "Expires on")
        #expect(RecipientDecryptionStatus.notEncryptedExpired.localizationKey == "Expired on")
        #expect(RecipientDecryptionStatus.valid.localizationKey == "Decryption until")
        #expect(RecipientDecryptionStatus.expired.localizationKey == "Decryption expired")
    }
}
