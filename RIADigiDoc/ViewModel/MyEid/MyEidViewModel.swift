// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import nfclib
import UtilsLib
import CommonsLib

@Observable
@MainActor
class MyEidViewModel: MyEidViewModelProtocol, Loggable {

    private let sharedMyEidSession: SharedMyEidSessionProtocol

    init(sharedMyEidSession: SharedMyEidSessionProtocol) {
        self.sharedMyEidSession = sharedMyEidSession
    }

    public func parseDateOfBirth(personalCode: String) -> String {
        do {
            return try DateUtil.getFormattedDateTime(
                date: DateOfBirthUtil.parseDateOfBirth(personalCode),
                isUTC: false
            )
            .date
        } catch {
            MyEidViewModel.logger().error(
                "Unable to parse date from personal code. \(error)"
            )
            return ""
        }
    }

    public func parseExpiryDate(expiryDate: String) -> String {
        return DateUtil
            .getFormattedDateTime(dateTimeString: expiryDate, isUTC: false, inputDateFormat: "dd.MM.yyyy")
            .date
    }

    public func setIsPinLocked(_ codeType: CodeType, isLocked: Bool) {
        sharedMyEidSession.setIsPinLocked(codeType, isLocked: isLocked)
    }

    public func getIsPinLocked(for codeType: CodeType) -> Bool {
        return sharedMyEidSession.getIsPinLocked(for: codeType)
    }

    public func setIsPinBlocked(_ codeType: CodeType, isBlocked: Bool) {
        sharedMyEidSession.setIsPinBlocked(codeType, isBlocked: isBlocked)
    }

    public func getIsPinBlocked(for codeType: CodeType) -> Bool {
        return sharedMyEidSession.getIsPinBlocked(for: codeType)
    }

    public func getDocumentExpirationStatus(expiryDate: String) -> MyEidDocumentStatus {
        let stringToDate = DateUtil.stringToDate(expiryDate, isUTC: false)
        guard let date = stringToDate else { return .unknown }
        let today = Calendar.current.startOfDay(for: Date())
        return (date < today) ? .expired : .valid
    }

}
