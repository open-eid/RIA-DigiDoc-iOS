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
import IdCardLib

@MainActor
protocol MyEidPinChangeViewModelProtocol: Sendable {
    var step: MyEidPinCodeStep { get }
    var input: String { get set }
    var inputErrorMessage: String? { get }
    var inputErrorMessageExtraArguments: [String] { get }
    var errorMessage: String? { get }
    var errorMessageExtraArguments: [String] { get }
    var isBlocked: Bool { get }

    func submit(nfcStringsUtil: NFCSessionStringsUtil) async
    func resetErrors()

    func verifyNewCode()
    func verifyRepeatedCode() -> Bool
    func isPINLengthValid(for codeType: CodeType, pin: [UInt8]) -> Bool
}
