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

import Foundation
import IdCardLib
import UtilsLib
import CommonsLib

@Observable
@MainActor
class MyEidViewModel: MyEidViewModelProtocol, Loggable {

    private let idCardRepository: IdCardRepositoryProtocol
    private let sharedMyEidSession: SharedMyEidSessionProtocol

    var usbReaderStatus: UsbReaderStatus {
        sharedMyEidSession.usbReaderStatus
    }

    init(
        idCardRepository: IdCardRepositoryProtocol,
        sharedMyEidSession: SharedMyEidSessionProtocol
    ) {
        self.idCardRepository = idCardRepository
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

    public func getIsPinBlocked(for codeType: CodeType) -> Bool {
        return sharedMyEidSession.getIsPinBlocked(for: codeType)
    }

    public func getDocumentExpirationStatus(expiryDate: String) -> MyEidDocumentStatus {
        let stringToDate = DateUtil.stringToDate(expiryDate, isUTC: false)
        guard let date = stringToDate else { return .unknown }
        let today = Calendar.current.startOfDay(for: Date())
        return (date < today) ? .expired : .valid
    }

    public func stopDiscoveringReaders() async {
        await idCardRepository.stopDiscoveringReaders()
        sharedMyEidSession.stopStatusStream()
    }
}
