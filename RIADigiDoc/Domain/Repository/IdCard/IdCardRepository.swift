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

actor IdCardRepository: IdCardRepositoryProtocol {
    private let idCardService: IdCardServiceProtocol

    init(
        idCardService: IdCardServiceProtocol
    ) {
        self.idCardService = idCardService
    }

    func startDiscoveringReaders() async {
        await idCardService.startDiscoveringReaders()
    }

    func stopDiscoveringReaders() async {
        await idCardService.stopDiscoveringReaders()
    }

    func statusStream() async -> AsyncStream<UsbReaderStatus> {
        await idCardService.statusStream()
    }

    func getCardHandler() async throws -> CardCommands {
        try await idCardService.getCardHandler()
    }

    func getPublicData() async throws -> CardInfo {
        try await idCardService.getPublicData()
    }

    func readAuthenticationCertificate() async throws -> Data {
        return try await idCardService.readAuthenticationCertificate()
    }

    func readSignatureCertificate() async throws -> Data {
        return try await idCardService.readSignatureCertificate()
    }

    func readCodeTryCounterRecord(for codeType: CodeType) async throws -> (retryCount: UInt8, pinActive: Bool) {
        return try await idCardService.readCodeTryCounterRecord(for: codeType)
    }

    func isPUKChangeable() async throws -> Bool {
        return try await idCardService.isPUKChangeable()
    }

    func changeCode(_ codeType: CodeType, to newCode: Data, verifyCode: Data) async throws {
        try await idCardService.changeCode(codeType, to: newCode, verifyCode: verifyCode)
    }

    func unblockCode(_ codeType: CodeType, puk: Data, newCode: Data) async throws {
        try await idCardService.unblockCode(codeType, puk: puk, newCode: newCode)
    }

    func calculateSignature(for dataToSign: Data, pin2: SecureData) async throws -> Data {
        try await idCardService.calculateSignature(for: dataToSign, pin2: pin2)
    }
}
