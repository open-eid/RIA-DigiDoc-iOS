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

import Testing
import IdCardLib

@MainActor
final class MyEidPinChangeViewModelTests {
    private let mockIdCardRepository: IdCardRepositoryProtocolMock
    private let mockSharedMyEidSession: SharedMyEidSessionProtocolMock
    private let mockOperationChangePin: OperationChangePinProtocolMock
    private let mockOperationUnblockPin: OperationUnblockPinProtocolMock

    public init() async throws {
        mockIdCardRepository = IdCardRepositoryProtocolMock()
        mockSharedMyEidSession = SharedMyEidSessionProtocolMock()
        mockOperationChangePin = OperationChangePinProtocolMock()
        mockOperationUnblockPin = OperationUnblockPinProtocolMock()
    }

    // MARK: - Helper methods

    private func makeNFCStringsUtil() -> NFCSessionStringsUtil {
        NFCSessionStringsUtil { key, _ in
            return key
        }
    }

    // MARK: - Initialization tests

    @Test
    func init_changePin1Success() async throws {
        let viewModel = MyEidPinChangeViewModel(
            pinAction: .change,
            codeType: .pin1,
            personalCode: "39001010000",
            actionMethod: .idCardViaNFC,
            idCardRepository: mockIdCardRepository,
            sharedMyEidSession: mockSharedMyEidSession,
            operationChangePin: mockOperationChangePin,
            operationUnblockPin: mockOperationUnblockPin
        )

        #expect(viewModel.personalCode == "39001010000")
        #expect(viewModel.pinAction == .change)
        #expect(viewModel.codeType == .pin1)
        #expect(viewModel.actionMethod == .idCardViaNFC)
        #expect(viewModel.step == .current)
        #expect(viewModel.isFirstStep == true)
    }

    @Test
    func init_unblockPin2Success() async throws {
        let viewModel = MyEidPinChangeViewModel(
            pinAction: .unblock,
            codeType: .pin2,
            personalCode: "39001010000",
            actionMethod: .idCardViaUSB,
            idCardRepository: mockIdCardRepository,
            sharedMyEidSession: mockSharedMyEidSession,
            operationChangePin: mockOperationChangePin,
            operationUnblockPin: mockOperationUnblockPin
        )

        #expect(viewModel.pinAction == .unblock)
        #expect(viewModel.codeType == .pin2)
        #expect(viewModel.actionMethod == .idCardViaUSB)
    }

    // MARK: - handleBackButton tests

    @Test
    func handleBackButton_doesNothingOnFirstStep() async throws {
        let viewModel = MyEidPinChangeViewModel(
            pinAction: .change,
            codeType: .pin1,
            personalCode: "39001010000",
            actionMethod: .idCardViaNFC,
            idCardRepository: mockIdCardRepository,
            sharedMyEidSession: mockSharedMyEidSession,
            operationChangePin: mockOperationChangePin,
            operationUnblockPin: mockOperationUnblockPin
        )

        viewModel.handleBackButton()

        #expect(viewModel.step == .current)
        #expect(viewModel.isFirstStep == true)
    }

    @Test
    func handleBackButton_goesBackToPreviousStep() async throws {
        let viewModel = MyEidPinChangeViewModel(
            pinAction: .change,
            codeType: .pin1,
            personalCode: "39001010000",
            actionMethod: .idCardViaNFC,
            idCardRepository: mockIdCardRepository,
            sharedMyEidSession: mockSharedMyEidSession,
            operationChangePin: mockOperationChangePin,
            operationUnblockPin: mockOperationUnblockPin
        )

        viewModel.input = "1234"
        await viewModel.submit(nfcStringsUtil: makeNFCStringsUtil())

        #expect(viewModel.step == .new)

        viewModel.handleBackButton()

        #expect(viewModel.step == .current)
        #expect(viewModel.input == "")
    }

    // MARK: - isPINLengthValid tests

    @Test
    func isPINLengthValid_pin1ValidLength() async throws {
        let viewModel = MyEidPinChangeViewModel(
            pinAction: .change,
            codeType: .pin1,
            personalCode: "39001010000",
            actionMethod: .idCardViaNFC,
            idCardRepository: mockIdCardRepository,
            sharedMyEidSession: mockSharedMyEidSession,
            operationChangePin: mockOperationChangePin,
            operationUnblockPin: mockOperationUnblockPin
        )

        let result = viewModel.isPINLengthValid(for: .pin1, pin: [49, 50, 51, 52]) // "1234"

        #expect(result == true)
    }

    @Test
    func isPINLengthValid_pin1TooShort() async throws {
        let viewModel = MyEidPinChangeViewModel(
            pinAction: .change,
            codeType: .pin1,
            personalCode: "39001010000",
            actionMethod: .idCardViaNFC,
            idCardRepository: mockIdCardRepository,
            sharedMyEidSession: mockSharedMyEidSession,
            operationChangePin: mockOperationChangePin,
            operationUnblockPin: mockOperationUnblockPin
        )

        let result = viewModel.isPINLengthValid(for: .pin1, pin: [49, 50, 51]) // "123"

        #expect(result == false)
    }

    @Test
    func isPINLengthValid_pin2ValidLength() async throws {
        let viewModel = MyEidPinChangeViewModel(
            pinAction: .change,
            codeType: .pin2,
            personalCode: "39001010000",
            actionMethod: .idCardViaNFC,
            idCardRepository: mockIdCardRepository,
            sharedMyEidSession: mockSharedMyEidSession,
            operationChangePin: mockOperationChangePin,
            operationUnblockPin: mockOperationUnblockPin
        )

        let result = viewModel.isPINLengthValid(for: .pin2, pin: [49, 50, 51, 52, 53]) // "12345"

        #expect(result == true)
    }

    @Test
    func isPINLengthValid_pin2TooShort() async throws {
        let viewModel = MyEidPinChangeViewModel(
            pinAction: .change,
            codeType: .pin2,
            personalCode: "39001010000",
            actionMethod: .idCardViaNFC,
            idCardRepository: mockIdCardRepository,
            sharedMyEidSession: mockSharedMyEidSession,
            operationChangePin: mockOperationChangePin,
            operationUnblockPin: mockOperationUnblockPin
        )

        let result = viewModel.isPINLengthValid(for: .pin2, pin: [49, 50, 51, 52]) // "1234"

        #expect(result == false)
    }

    @Test
    func isPINLengthValid_pukValidLength() async throws {
        let viewModel = MyEidPinChangeViewModel(
            pinAction: .unblock,
            codeType: .pin1,
            personalCode: "39001010000",
            actionMethod: .idCardViaNFC,
            idCardRepository: mockIdCardRepository,
            sharedMyEidSession: mockSharedMyEidSession,
            operationChangePin: mockOperationChangePin,
            operationUnblockPin: mockOperationUnblockPin
        )

        let result = viewModel.isPINLengthValid(for: .puk, pin: [49, 50, 51, 52, 53, 54, 55, 56]) // "12345678"

        #expect(result == true)
    }

    @Test
    func isPINLengthValid_pukTooShort() async throws {
        let viewModel = MyEidPinChangeViewModel(
            pinAction: .change,
            codeType: .puk,
            personalCode: "39001010000",
            actionMethod: .idCardViaNFC,
            idCardRepository: mockIdCardRepository,
            sharedMyEidSession: mockSharedMyEidSession,
            operationChangePin: mockOperationChangePin,
            operationUnblockPin: mockOperationUnblockPin
        )

        let result = viewModel.isPINLengthValid(for: .puk, pin: [49, 50, 51, 52, 53, 54, 55]) // "1234567"

        #expect(result == false)
    }

    @Test
    func isPINLengthValid_containsNonNumeric() async throws {
        let viewModel = MyEidPinChangeViewModel(
            pinAction: .change,
            codeType: .pin1,
            personalCode: "39001010000",
            actionMethod: .idCardViaNFC,
            idCardRepository: mockIdCardRepository,
            sharedMyEidSession: mockSharedMyEidSession,
            operationChangePin: mockOperationChangePin,
            operationUnblockPin: mockOperationUnblockPin
        )

        let result = viewModel.isPINLengthValid(for: .pin1, pin: [49, 50, 97, 98]) // "12ab"

        #expect(result == false)
    }

    // MARK: - verifyNewCode tests

    @Test
    func verifyNewCode_validPin() async throws {
        let viewModel = MyEidPinChangeViewModel(
            pinAction: .change,
            codeType: .pin1,
            personalCode: "39001010000",
            actionMethod: .idCardViaNFC,
            idCardRepository: mockIdCardRepository,
            sharedMyEidSession: mockSharedMyEidSession,
            operationChangePin: mockOperationChangePin,
            operationUnblockPin: mockOperationUnblockPin
        )

        viewModel.input = "4827"
        viewModel.verifyNewCode()

        #expect(viewModel.inputErrorMessage == nil)
    }

    @Test
    func verifyNewCode_tooEasySameDigits() async throws {
        let viewModel = MyEidPinChangeViewModel(
            pinAction: .change,
            codeType: .pin1,
            personalCode: "39001010000",
            actionMethod: .idCardViaNFC,
            idCardRepository: mockIdCardRepository,
            sharedMyEidSession: mockSharedMyEidSession,
            operationChangePin: mockOperationChangePin,
            operationUnblockPin: mockOperationUnblockPin
        )

        viewModel.input = "1111"
        viewModel.verifyNewCode()

        #expect(viewModel.step == .current)
        #expect(viewModel.inputErrorMessage == "PIN too easy")
        #expect(viewModel.inputErrorMessageExtraArguments == [CodeType.pin1.name])
    }

    @Test
    func verifyNewCode_partOfPersonalCode() async throws {
        let viewModel = MyEidPinChangeViewModel(
            pinAction: .change,
            codeType: .pin1,
            personalCode: "39001010000",
            actionMethod: .idCardViaNFC,
            idCardRepository: mockIdCardRepository,
            sharedMyEidSession: mockSharedMyEidSession,
            operationChangePin: mockOperationChangePin,
            operationUnblockPin: mockOperationUnblockPin
        )

        viewModel.input = "0101"
        viewModel.verifyNewCode()

        #expect(viewModel.inputErrorMessage == "PIN part of personal code")
        #expect(viewModel.inputErrorMessageExtraArguments == [CodeType.pin1.name])
    }

    @Test
    func verifyNewCode_birthDateVariant() async throws {
        let viewModel = MyEidPinChangeViewModel(
            pinAction: .change,
            codeType: .pin1,
            personalCode: "39001010000",
            actionMethod: .idCardViaNFC,
            idCardRepository: mockIdCardRepository,
            sharedMyEidSession: mockSharedMyEidSession,
            operationChangePin: mockOperationChangePin,
            operationUnblockPin: mockOperationUnblockPin
        )

        viewModel.input = "1990"
        viewModel.verifyNewCode()

        #expect(viewModel.inputErrorMessage == "PIN part of date of birth")
        #expect(viewModel.inputErrorMessageExtraArguments == [CodeType.pin1.name])
    }

    // MARK: - verifyRepeatedCode tests

    @Test
    func verifyRepeatedCode_returnsTrue() async throws {
        let viewModel = MyEidPinChangeViewModel(
            pinAction: .change,
            codeType: .pin1,
            personalCode: "39001010000",
            actionMethod: .idCardViaNFC,
            idCardRepository: mockIdCardRepository,
            sharedMyEidSession: mockSharedMyEidSession,
            operationChangePin: mockOperationChangePin,
            operationUnblockPin: mockOperationUnblockPin
        )

        viewModel.input = "4862"
        await viewModel.submit(nfcStringsUtil: makeNFCStringsUtil())

        #expect(viewModel.step == .new)
        viewModel.input = "8261"
        await viewModel.submit(nfcStringsUtil: makeNFCStringsUtil())
        #expect(viewModel.step == .confirm)
        viewModel.input = "8261"
        let result = viewModel.verifyRepeatedCode()

        #expect(result == true)
    }

    @Test
    func verifyRepeatedCode_returnsFalse() async throws {
        let viewModel = MyEidPinChangeViewModel(
            pinAction: .change,
            codeType: .pin1,
            personalCode: "39001010000",
            actionMethod: .idCardViaNFC,
            idCardRepository: mockIdCardRepository,
            sharedMyEidSession: mockSharedMyEidSession,
            operationChangePin: mockOperationChangePin,
            operationUnblockPin: mockOperationUnblockPin
        )

        viewModel.input = "4862"
        await viewModel.submit(nfcStringsUtil: makeNFCStringsUtil())

        viewModel.input = "8261"
        await viewModel.submit(nfcStringsUtil: makeNFCStringsUtil())

        viewModel.input = "6284"
        let result = viewModel.verifyRepeatedCode()

        #expect(result == false)
    }

    // MARK: - resetErrors tests

    @Test
    func resetErrors_clearsAllErrors() async throws {
        let viewModel = MyEidPinChangeViewModel(
            pinAction: .change,
            codeType: .pin1,
            personalCode: "39001010000",
            actionMethod: .idCardViaNFC,
            idCardRepository: mockIdCardRepository,
            sharedMyEidSession: mockSharedMyEidSession,
            operationChangePin: mockOperationChangePin,
            operationUnblockPin: mockOperationUnblockPin
        )

        viewModel.input = "1111"
        viewModel.verifyNewCode()

        #expect(viewModel.inputErrorMessage != nil)

        viewModel.resetErrors()

        #expect(viewModel.inputErrorMessage == nil)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isBlocked == false)
        #expect(viewModel.isSuccess == false)
    }

    // MARK: - handleConfirmStepError tests

    @Test
    func handleConfirmStepError_setsErrorOnConfirmStep() async throws {
        let viewModel = MyEidPinChangeViewModel(
            pinAction: .change,
            codeType: .pin1,
            personalCode: "39001010000",
            actionMethod: .idCardViaNFC,
            idCardRepository: mockIdCardRepository,
            sharedMyEidSession: mockSharedMyEidSession,
            operationChangePin: mockOperationChangePin,
            operationUnblockPin: mockOperationUnblockPin
        )

        viewModel.input = "4063"
        await viewModel.submit(nfcStringsUtil: makeNFCStringsUtil())
        viewModel.input = "8061"
        await viewModel.submit(nfcStringsUtil: makeNFCStringsUtil())

        viewModel.input = "1234"
        viewModel.handleConfirmStepError()

        #expect(viewModel.inputErrorMessage == "PIN repeat error")
        #expect(viewModel.inputErrorMessageExtraArguments == [CodeType.pin1.name])
    }

    // MARK: - Submit confirm step

    @Test
    func submit_performsNFCCodeChange() async throws {
        let viewModel = MyEidPinChangeViewModel(
            pinAction: .change,
            codeType: .pin1,
            personalCode: "39001010000",
            actionMethod: .idCardViaNFC,
            idCardRepository: mockIdCardRepository,
            sharedMyEidSession: mockSharedMyEidSession,
            operationChangePin: mockOperationChangePin,
            operationUnblockPin: mockOperationUnblockPin
        )

        viewModel.input = "4862"
        await viewModel.submit(nfcStringsUtil: makeNFCStringsUtil())

        viewModel.input = "8261"
        await viewModel.submit(nfcStringsUtil: makeNFCStringsUtil())

        viewModel.input = "8261"
        await viewModel.submit(nfcStringsUtil: makeNFCStringsUtil())

        #expect(mockOperationChangePin.startChangingCallCount == 1)
    }

    @Test
    func submit_performsNFCCodeUnblock() async throws {
        let viewModel = MyEidPinChangeViewModel(
            pinAction: .unblock,
            codeType: .pin1,
            personalCode: "39001010000",
            actionMethod: .idCardViaNFC,
            idCardRepository: mockIdCardRepository,
            sharedMyEidSession: mockSharedMyEidSession,
            operationChangePin: mockOperationChangePin,
            operationUnblockPin: mockOperationUnblockPin
        )

        viewModel.input = "48623423"
        await viewModel.submit(nfcStringsUtil: makeNFCStringsUtil())

        viewModel.input = "8261"
        await viewModel.submit(nfcStringsUtil: makeNFCStringsUtil())

        viewModel.input = "8261"
        await viewModel.submit(nfcStringsUtil: makeNFCStringsUtil())

        #expect(mockOperationUnblockPin.startReadingCallCount == 1)
    }
}
