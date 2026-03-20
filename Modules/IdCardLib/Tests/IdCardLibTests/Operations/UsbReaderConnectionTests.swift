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
import Testing
import IdCardLibMocks

@testable import IdCardLib

struct UsbReaderConnectionTests {

    private let mockCardCommands: CardCommandsMock
    private let usbReaderConnection: UsbReaderConnection

    init() async throws {
        mockCardCommands = CardCommandsMock()
        usbReaderConnection = UsbReaderConnection()
    }

    @Test
    func calculateSignature_success() async throws {
        let expectedSignature = Data([0x01, 0x02])
        let inputData = Data([0xAA])
        let pin2 = SecureData([1, 2, 3, 4, 5])

        mockCardCommands.calculateSignatureHandler = { _, _ in
            expectedSignature
        }

        await usbReaderConnection.setCardHandler(mockCardCommands)

        let result = try await usbReaderConnection.calculateSignature(
            for: inputData,
            pin2: pin2
        )

        #expect(result == expectedSignature)
    }

    @Test
    func calculateSignature_throwReaderProcessFailedErrorWhenCardHandlerNil() async throws {
        let inputData = Data()
        let pin2 = SecureData([1, 2, 3, 4, 5])

        await usbReaderConnection.setCardHandler(nil)

        await #expect(throws: IdCardInternalError.readerProcessFailed) {
            try await usbReaderConnection.calculateSignature(
                for: inputData,
                pin2: pin2
            )
        }
    }

    @Test
    func calculateSignature_throwSessionErrorWhenUnknownErrorThrown() async throws {
        let inputData = Data()
        let pin2 = SecureData([1, 2, 3, 4, 5])

        mockCardCommands.calculateSignatureHandler = { _, _ in
            throw NSError(domain: "Test", code: 1)
        }

        await usbReaderConnection.setCardHandler(mockCardCommands)

        await #expect(throws: IdCardError.sessionError) {
            try await usbReaderConnection.calculateSignature(
                for: inputData,
                pin2: pin2
            )
        }
    }

    @Test
    func calculateSignature_throwIdCardErrorWhenInternalErrorThrown() async throws {
        let inputData = Data()
        let pin2 = SecureData([1, 2, 3, 4, 5])
        let internalError = IdCardInternalError.connectionFailed

        mockCardCommands.calculateSignatureHandler = { _, _ in
            throw internalError
        }

        await usbReaderConnection.setCardHandler(mockCardCommands)

        await #expect(throws: internalError.getIdCardError()) {
            try await usbReaderConnection.calculateSignature(
                for: inputData,
                pin2: pin2
            )
        }
    }
}
