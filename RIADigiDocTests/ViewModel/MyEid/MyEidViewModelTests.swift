// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import Testing

@MainActor
final class MyEidViewModelTests {
    private let mockSharedMyEidSession: SharedMyEidSessionProtocolMock
    private let viewModel: MyEidViewModel

    public init() async throws {
        mockSharedMyEidSession = SharedMyEidSessionProtocolMock()
        viewModel = MyEidViewModel(sharedMyEidSession: mockSharedMyEidSession)
    }

    // MARK: - Helper methods

    private func certificateDate(daysFromToday days: Int) throws -> String {
        let calendar = Calendar.current
        let day = try #require(
            calendar.date(byAdding: .day, value: days, to: calendar.startOfDay(for: Date()))
        )

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: day)
    }

    // MARK: - getDocumentExpirationStatus tests

    @Test
    func getDocumentExpirationStatus_returnsExpiredWhenDateHasPassed() throws {
        let yesterday = try certificateDate(daysFromToday: -1)

        #expect(viewModel.getDocumentExpirationStatus(expiryDate: yesterday) == .expired)
    }

    @Test
    func getDocumentExpirationStatus_returnsValidOnTheExpiryDayItself() throws {
        let today = try certificateDate(daysFromToday: 0)

        #expect(viewModel.getDocumentExpirationStatus(expiryDate: today) == .valid)
    }

    @Test
    func getDocumentExpirationStatus_returnsValidWhenDateIsInTheFuture() throws {
        let tomorrow = try certificateDate(daysFromToday: 1)

        #expect(viewModel.getDocumentExpirationStatus(expiryDate: tomorrow) == .valid)
    }

    // MARK: - getCertificateStatus tests

    @Test
    func getCertificateStatus_returnsExpiredOneSecondAfterTheCertificateInstant() {
        let justExpired = Date().addingTimeInterval(-1)

        #expect(viewModel.getCertificateStatus(notValidAfter: justExpired) == .expired)
    }

    @Test
    func getCertificateStatus_returnsValidOneSecondBeforeTheCertificateInstant() {
        let aboutToExpire = Date().addingTimeInterval(1)

        #expect(viewModel.getCertificateStatus(notValidAfter: aboutToExpire) == .valid)
    }

    @Test
    func getCertificateStatus_returnsExpiredForAnInstantEarlierToday() {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let earlierToday = startOfDay.addingTimeInterval(now.timeIntervalSince(startOfDay) / 2)

        #expect(calendar.isDateInToday(earlierToday))
        #expect(viewModel.getCertificateStatus(notValidAfter: earlierToday) == .expired)
    }

    @Test
    func getCertificateStatus_returnsUnknownWhenTheDateIsMissing() {
        #expect(viewModel.getCertificateStatus(notValidAfter: nil) == .unknown)
    }

    @Test
    func getDocumentExpirationStatus_returnsUnknownWhenDateIsEmpty() {
        #expect(viewModel.getDocumentExpirationStatus(expiryDate: "") == .unknown)
    }

    @Test
    func getDocumentExpirationStatus_returnsUnknownWhenDateIsNotParseable() {
        #expect(viewModel.getDocumentExpirationStatus(expiryDate: "not a date") == .unknown)
    }
}
