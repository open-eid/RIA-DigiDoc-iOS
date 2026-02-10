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
import CommonsLib
import UtilsLib

@MainActor
@Observable
final class MyEidPinChangeViewModel: MyEidPinChangeViewModelProtocol, Loggable {
    private(set) var pinAction: MyEidPinCodeAction
    private(set) var codeType: CodeType
    private(set) var personalCode: String

    private(set) var steps: [MyEidPinCodeStep] = []
    private(set) var stepIndex: Int = 0

    private(set) var currentCode: [UInt8]?
    private(set) var newCode: [UInt8]?

    private(set) var isSuccess: Bool = false
    private(set) var step: MyEidPinCodeStep = .current
    var input: String = ""
    private(set) var inputErrorMessage: String?
    private(set) var inputErrorMessageExtraArguments: [String] = []
    private(set) var errorMessage: String?
    private(set) var errorMessageExtraArguments: [String] = []
    private(set) var isBlocked: Bool = false

    private let idCardRepository: IdCardRepositoryProtocol
    private let sharedMyEidSession: SharedMyEidSessionProtocol

    var usbReaderStatus: UsbReaderStatus {
        sharedMyEidSession.usbReaderStatus
    }

    var isFirstStep: Bool {
        stepIndex == 0
    }

    init(
        pinAction: MyEidPinCodeAction,
        codeType: CodeType,
        personalCode: String,
        idCardRepository: IdCardRepositoryProtocol,
        sharedMyEidSession: SharedMyEidSessionProtocol
    ) {
        self.pinAction = pinAction
        self.codeType = codeType
        self.personalCode = personalCode
        self.idCardRepository = idCardRepository
        self.sharedMyEidSession = sharedMyEidSession

        configure(pinAction: pinAction, codeType: codeType)
    }

    func handleBackButton() {
        resetInputError()
        resetErrorMessage()
        if stepIndex > 0 {
            stepIndex -= 1
            step = steps[stepIndex]
            input = ""
        }
    }

    func submit() async {
        resetInputError()
        resetErrorMessage()

        switch step {
        case .current:
            setCurrentCode(input)
            advance()
        case .new:
            verifyNewCode()
            guard inputErrorMessage == nil else {
                return
            }
            setNewCode(input)
            advance()
        case .confirm:
            guard verifyRepeatedCode() else {
                handleConfirmStepError()
                clearPinCodes()
                return
            }

            guard let currentPinCode = currentCode, let newPinCode = newCode else {
                input = ""
                clearPinCodes()
                errorMessage = "General error"
                resetToCurrentPinEntryStep()
                return
            }

            await performCodeChange(
                pinAction,
                codeType: codeType,
                current: currentPinCode,
                new: newPinCode
            )
        }

        input = ""
    }

    func resetErrors() {
        resetInputError()
        resetErrorMessage()
        isBlocked = false
        resetToCurrentPinEntryStep()
        isSuccess = false
    }

    func handleConfirmStepError() {
        if step == .confirm && !verifyRepeatedCode() {
            inputErrorMessage = "PIN repeat error"
            inputErrorMessageExtraArguments = [codeType.name]
        } else {
            resetInputError()
        }
    }

    func resetConfirmStepError() {
        resetInputError()
    }

    func isPINLengthValid(for codeType: CodeType, pin: [UInt8]) -> Bool {
        guard codeType.validLength.contains(pin.count) else {
            return false
        }

        return pin.allSatisfy {
            return Character(UnicodeScalar($0)).isNumber
        }
    }

    func verifyNewCode() {
        let newCode = Array(input.utf8)

        if containsSameDigits(pin: newCode) || isCodeTooEasy(pin: newCode) {
            inputErrorMessage = "PIN too easy"
            inputErrorMessageExtraArguments = [codeType.name]
            return
        }

        if isPartOfPersonalCode(pin: newCode, personalCode: personalCode) {
            inputErrorMessage = "PIN part of personal code"
            inputErrorMessageExtraArguments = [codeType.name]
            return
        }

        if isPinBirthDateVariant(pin: newCode, personalCode: personalCode) {
            inputErrorMessage = "PIN part of date of birth"
            inputErrorMessageExtraArguments = [codeType.name]
            return
        }

        resetInputError()
    }

    func verifyRepeatedCode() -> Bool {
        guard let newCode = newCode else { return false }
        return input.utf8.elementsEqual(newCode)
    }

    private func resetInputError() {
        inputErrorMessage = nil
        inputErrorMessageExtraArguments = []
    }

    private func resetErrorMessage() {
        errorMessage = nil
        errorMessageExtraArguments = []
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

    private func clearPinCodes() {
        currentCode?.resetAllBytes()
        newCode?.resetAllBytes()
        currentCode = nil
        newCode = nil
    }

    private func performCodeChange(
        _ action: MyEidPinCodeAction,
        codeType: CodeType,
        current: [UInt8],
        new: [UInt8]
    ) async {
        do {
            switch action {
            case .change:
                try await idCardRepository.changeCode(
                    codeType,
                    to: Data(new),
                    verifyCode: Data(current)
                )
            case .unblock:
                try await idCardRepository
                    .unblockCode(codeType, puk: Data(current), newCode: Data(new))
                sharedMyEidSession.setIsPinBlocked(codeType, isBlocked: false)
            }
            isSuccess = true
        } catch {
            MyEidPinChangeViewModel.logger().error("Unable to change or unblock PIN. \(error)")

            if let pinCodeChangeError = error as? IdCardError {
                handleError(pinCodeChangeError)
            } else {
                errorMessage = "General error"
            }

            isSuccess = false
        }

        clearPinCodes()
    }

    private func handleError(_ error: IdCardError) {
        switch error {
        case .wrongPIN(triesLeft: 0):
            errorMessage = "PIN blocked"
            errorMessageExtraArguments = [codeType.name]
            isBlocked = true
            sharedMyEidSession.setIsPinBlocked(codeType, isBlocked: true)
        case .wrongPIN(let remaining):
            errorMessage = remaining > 1 ? "PIN verification error multiple" : "PIN verification error one"
            errorMessageExtraArguments = [
                pinAction == .change ? codeType.name : CodeType.puk.name, String(remaining)
            ]
            resetToCurrentPinEntryStep()
        default:
            resetInputError()
            errorMessage = "General error"
            resetToCurrentPinEntryStep()
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

    private func isCodeTooEasy(pin: [UInt8]) -> Bool {
        let digits = pin.compactMap { byte -> Int? in
            return Character(UnicodeScalar(byte)).wholeNumberValue
        }

        guard digits.count == pin.count else { return false }

        let ascending = zip(digits, digits.dropFirst()).allSatisfy {
            ($0 + 1) % 10 == $1
        }

        let descending = zip(digits, digits.dropFirst()).allSatisfy {
            ($0 + 9) % 10 == $1
        }

        return ascending || descending
    }

    private func containsSameDigits(pin: [UInt8]) -> Bool {
        guard let first = pin.first else { return false }
        return pin.allSatisfy { $0 == first }
    }

    private func isPartOfPersonalCode(pin: [UInt8], personalCode: String) -> Bool {
        guard
            let data = personalCode.data(using: .ascii),
            !pin.isEmpty,
            pin.count <= data.count
        else { return false }

        for start in data.indices {
            let end = start + pin.count
            guard end <= data.endIndex else { break }

            if data[start..<end].elementsEqual(pin) {
                return true
            }
        }
        return false
    }

    private func isPinBirthDateVariant(pin: [UInt8], personalCode: String) -> Bool {
        let dateOfBirth: String?
        do {
            dateOfBirth = try DateUtil.getFormattedDateTime(
                date: DateOfBirthUtil.parseDateOfBirth(personalCode),
                isUTC: false
            )
            .date
        } catch {
            MyEidPinChangeViewModel.logger().error(
                "Unable to parse date from personal code. \(error)"
            )

            dateOfBirth = nil
        }

        guard let dateOfBirth,
              let birthDate = DateUtil.stringToDate(dateOfBirth, isUTC: true) else {
            return false
        }

        let components = Calendar.current.dateComponents([.year, .month, .day], from: birthDate)
        guard let year = components.year,
              let month = components.month,
              let day = components.day else { return false }

        let birthDateFormatted = String(format: "%02d%02d%04d", day, month, year)

        let birthDateBytes = Array(birthDateFormatted.utf8)

        guard !pin.isEmpty, pin.count <= birthDateBytes.count else {
            return false
        }

        for start in birthDateBytes.indices {
            let end = start + pin.count
            guard end <= birthDateBytes.endIndex else { break }

            if birthDateBytes[start..<end].elementsEqual(pin) {
                return true
            }
        }

        return false
    }
}

extension Array where Element == UInt8 {
    mutating func resetAllBytes() {
        for indice in indices { self[indice] = 0 }
    }
}
