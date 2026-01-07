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

@MainActor
@Observable
final class MyEidPinChangeViewModel: MyEidPinChangeViewModelProtocol {
    private(set) var pinAction: MyEidPinCodeAction
    private(set) var codeType: CodeType

    private(set) var steps: [MyEidPinCodeStep] = []
    private(set) var stepIndex: Int = 0

    private(set) var currentCode: [UInt8]?
    private(set) var newCode: [UInt8]?

    private(set) var isSuccess: Bool = false
    private(set) var step: MyEidPinCodeStep = .current
    var input: String = ""
    private(set) var errorMessage: String?
    private(set) var errorMessageExtraArguments: [String] = []

    var isFirstStep: Bool {
        stepIndex == 0
    }

    init(
        pinAction: MyEidPinCodeAction,
        codeType: CodeType
    ) {
        self.pinAction = pinAction
        self.codeType = codeType

        configure(pinAction: pinAction, codeType: codeType)
    }

    func handleBackButton() {
        errorMessage = nil
        errorMessageExtraArguments = []
        if stepIndex > 0 {
            stepIndex -= 1
            step = steps[stepIndex]
            input = ""
        }
    }

    func submit() async {
        errorMessage = nil
        errorMessageExtraArguments = []

        switch step {
        case .current:
            setCurrentCode(input)
            advance()
        case .new:
            setNewCode(input)
            advance()
        case .confirm:
            guard verifyRepeatedCode() else {
                errorMessage = "PIN repeat error"
                errorMessageExtraArguments = [codeType.name]
                clearPinCodes()
                return
            }

            guard let currentPinCode = currentCode, let newPinCode = newCode else {
                input = ""
                clearPinCodes()
                errorMessage = "General error"
                return
            }

            await performCodeChange(current: currentPinCode, new: newPinCode)
        }

        input = ""
    }

    private func configure(pinAction: MyEidPinCodeAction, codeType: CodeType) {
        self.pinAction = pinAction
        self.codeType = codeType
        self.steps = pinAction.steps()
        self.stepIndex = 0
        self.step = steps[0]
    }

    private func advance() {
        stepIndex += 1
        if stepIndex < steps.count {
            step = steps[stepIndex]
        }
    }

    private func setCurrentCode(_ code: String) {
        currentCode = Array(code.utf8)
        input = ""
    }

    private func setNewCode(_ code: String) {
        newCode = Array(code.utf8)
        input = ""
    }

    private func verifyRepeatedCode() -> Bool {
        guard let newCode = newCode else { return false }
        return input.utf8.elementsEqual(newCode)
    }

    private func clearPinCodes() {
        currentCode?.resetAllBytes()
        newCode?.resetAllBytes()
        currentCode = nil
        newCode = nil
    }

    private func performCodeChange(current: [UInt8], new: [UInt8]) async {
        currentCode = current
        newCode = new

        // TODO: Implement code change
        isSuccess = true
        clearPinCodes()
    }

    private func handleError(_ error: MyEidPinCodeChangeError) {
        switch error {
        case .invalidCurrentCode(let remaining):
            errorMessage = "PIN verification error"
            errorMessageExtraArguments = [codeType.name, String(remaining)]
            resetToCurrentPinEntryStep()
        case .blocked:
            errorMessage = "PIN blocked"
            errorMessageExtraArguments = [codeType.name]
        }
        clearPinCodes()
    }

    private func resetToCurrentPinEntryStep() {
        stepIndex = 0
        step = steps[0]
        currentCode = nil
        newCode = nil
        input = ""
    }
}

extension Array where Element == UInt8 {
    mutating func resetAllBytes() {
        for indice in indices { self[indice] = 0 }
    }
}
