// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import nfclib

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
