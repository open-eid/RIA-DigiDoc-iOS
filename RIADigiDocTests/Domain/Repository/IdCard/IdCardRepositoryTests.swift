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
import Testing
import IdCardLib
import IdCardLibMocks

struct IdCardRepositoryTests {

    private let mockIdCardService: IdCardServiceProtocolMock
    private let repository: IdCardRepository

    init() async throws {
        mockIdCardService = IdCardServiceProtocolMock()
        repository = IdCardRepository(
            idCardService: mockIdCardService
        )
    }

    @Test
    func startDiscoveringReaders_success() async throws {
        await repository.startDiscoveringReaders()

        #expect(mockIdCardService.startDiscoveringReadersCallCount == 1)
    }

    @Test
    func stopDiscoveringReaders_success() async throws {
        await repository.stopDiscoveringReaders()

        #expect(mockIdCardService.stopDiscoveringReadersCallCount == 1)
    }

    @Test
    func getCardHandler_success() async throws {
        let mockCardCommands = CardCommandsMock()

        mockIdCardService.getCardHandlerHandler = {
            mockCardCommands
        }

        let result = try await repository.getCardHandler()

        #expect(result as? CardCommandsMock === mockCardCommands)
        #expect(mockIdCardService.getCardHandlerCallCount == 1)
    }

    @Test
    func getCardHandler_throwIdCardInternalErrorWhenConnectionFailed() async throws {
        mockIdCardService.getCardHandlerHandler = {
            throw IdCardInternalError.connectionFailed
        }

        await #expect(throws: IdCardInternalError.connectionFailed) {
            try await repository.getCardHandler()
        }
    }

    @Test
    func readAuthenticationCertificate_success() async throws {
        let expected = Data([0x01])

        mockIdCardService.readAuthenticationCertificateHandler = {
            expected
        }

        let result = try await repository.readAuthenticationCertificate()

        #expect(result == expected)
    }

    @Test
    func readSignatureCertificate_success() async throws {
        let expected = Data([0x02])

        mockIdCardService.readSignatureCertificateHandler = {
            expected
        }

        let result = try await repository.readSignatureCertificate()

        #expect(result == expected)
    }

    @Test
    func readCodeTryCounterRecord_success() async throws {
        let expected: (retryCount: UInt8, pinActive: Bool) = (3, true)

        mockIdCardService.readCodeTryCounterRecordHandler = { _ in
            expected
        }

        let result = try await repository.readCodeTryCounterRecord(for: .pin1)

        #expect(result.retryCount == expected.retryCount)
        #expect(result.pinActive == expected.pinActive)
    }

    @Test
    func isPUKChangeable_success() async throws {
        mockIdCardService.isPUKChangeableHandler = {
            true
        }

        let result = try await repository.isPUKChangeable()

        #expect(result)
    }

    @Test
    func changeCode_success() async throws {
        await #expect(throws: Never.self) {
            try await repository.changeCode(
                .pin1,
                to: Data([0x01]),
                verifyCode: Data([0x02])
            )
        }

        #expect(mockIdCardService.changeCodeCallCount == 1)
    }

    @Test
    func unblockCode_success() async throws {
        await #expect(throws: Never.self) {
            try await repository.unblockCode(
                .pin1,
                puk: Data([0x00]),
                newCode: Data([0x01])
            )
        }

        #expect(mockIdCardService.unblockCodeCallCount == 1)
    }

    @Test
    func calculateSignature_success() async throws {
        let expected = Data([0xAB])
        let pin2 = SecureData([1, 2, 3, 4, 5])

        mockIdCardService.calculateSignatureHandler = { _, _ in
            expected
        }

        let result = try await repository.calculateSignature(
            for: Data([0x01]),
            pin2: pin2
        )

        #expect(result == expected)
        #expect(mockIdCardService.calculateSignatureCallCount == 1)
    }

    @Test
    func calculateSignature_throwConnectionFailedErrorWhenUnableToCalculateSignature() async throws {
        mockIdCardService.calculateSignatureHandler = { _, _ in
            throw IdCardInternalError.connectionFailed
        }

        await #expect(throws: IdCardInternalError.connectionFailed) {
            try await repository.calculateSignature(
                for: Data(),
                pin2: SecureData([1, 2, 3, 4, 5])
            )
        }
    }
}
