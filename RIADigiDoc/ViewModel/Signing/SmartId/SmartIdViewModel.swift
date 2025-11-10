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
import OSLog
import Alamofire
import MobileIdLib
import LibdigidocLibSwift
import UtilsLib
import ConfigLib
import CommonsLib

@MainActor
class SmartIdViewModel: SmartIdViewModelProtocol, ObservableObject {
    private static let logger = Logger(
        subsystem: "ee.ria.digidoc.RIADigiDoc",
        category: "SmartIdViewModel"
    )

    @Published var controlCode: String = "- - - -"

    @Published var personalCodeErrorKey: String?

    func isSigningEnabled(
        personalCode: String
    ) -> Bool {
        checkPersonalCodeValidity(personalCode)
        return !personalCode.isEmpty && personalCodeErrorKey?.isEmpty == true
    }

    private func checkPersonalCodeValidity(_ personalCode: String) {
        guard personalCode.isEmpty || PersonalCodeValidator.isPersonalCodeValid(personalCode) else {
            personalCodeErrorKey = "Invalid personal code"
            return
        }
        personalCodeErrorKey = ""
    }
}
