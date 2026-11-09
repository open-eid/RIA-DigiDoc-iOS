// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import Testing
import LibdigidocLibSwift

@MainActor
final class SignatureUtilTests {

    @Test(arguments: [SignatureStatus.valid, .warning, .nonQSCD])
    func showsStatusBadge_hidesStatusForValidSignatureWithArchiveTimestamp(status: SignatureStatus) {
        #expect(SignatureUtil.showsStatusBadge(status: status, hasArchiveTimestamp: true) == false)
    }

    @Test(arguments: [SignatureStatus.unknown, .invalid])
    func showsStatusBadge_keepsStatusForNonValidSignatureWithArchiveTimestamp(status: SignatureStatus) {
        #expect(SignatureUtil.showsStatusBadge(status: status, hasArchiveTimestamp: true) == true)
    }

    @Test(arguments: [SignatureStatus.valid, .warning, .nonQSCD, .invalid, .unknown])
    func showsStatusBadge_keepsStatusWhenThereIsNoArchiveTimestamp(status: SignatureStatus) {
        #expect(SignatureUtil.showsStatusBadge(status: status, hasArchiveTimestamp: false) == true)
    }

    @Test(arguments: [SignatureStatus.unknown, .invalid])
    func isArchiveTimestampExpired_marksTimestampExpiredWhenSignatureIsNotValid(status: SignatureStatus) {
        #expect(SignatureUtil.isArchiveTimestampExpired(status: status, isPastValidUntil: false) == true)
    }

    @Test
    func isArchiveTimestampExpired_marksTimestampExpiredWhenPastValidUntil() {
        #expect(SignatureUtil.isArchiveTimestampExpired(status: .valid, isPastValidUntil: true) == true)
    }

    @Test(arguments: [SignatureStatus.valid, .warning, .nonQSCD])
    func isArchiveTimestampExpired_marksTimestampValidWhenSignatureIsValidAndNotPastValidUntil(
        status: SignatureStatus
    ) {
        #expect(SignatureUtil.isArchiveTimestampExpired(status: status, isPastValidUntil: false) == false)
    }
}
