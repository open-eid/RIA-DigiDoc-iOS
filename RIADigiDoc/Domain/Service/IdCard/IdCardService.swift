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

actor IdCardService: IdCardServiceProtocol {
    private let usbReaderConnection: UsbReaderConnectionProtocol

    init(usbReaderConnection: UsbReaderConnectionProtocol) {
        self.usbReaderConnection = usbReaderConnection
    }

    public func startDiscoveringReaders() async {
        await usbReaderConnection.startDiscoveringReaders()
    }

    public func stopDiscoveringReaders() async {
        await usbReaderConnection.stopDiscoveringReaders(with: .sInitial)
    }

    public func statusStream() async -> AsyncStream<UsbReaderStatus> {
        await usbReaderConnection.statusStream()
    }

    public func getPublicData() async throws -> CardInfo {
        return try await usbReaderConnection.getPublicData()
    }

    public func getCardHandler() async throws -> CardCommands {
        return try await usbReaderConnection.getCardHandler()
    }

    func readAuthenticationCertificate() async throws -> Data {
        return try await usbReaderConnection.readAuthenticationCertificate()
    }

    func readSignatureCertificate() async throws -> Data {
        return try await usbReaderConnection.readSignatureCertificate()
    }

    func readCodeTryCounterRecord(for codeType: CodeType) async throws -> UInt8 {
        return try await usbReaderConnection.readCodeTryCounterRecord(for: codeType)
    }

    func isPUKChangeable() async throws -> Bool {
        return try await usbReaderConnection.isPUKChangeable()
    }

    func changeCode(_ codeType: CodeType, to newCode: Data, verifyCode: Data) async throws {
        try await usbReaderConnection.changeCode(codeType, to: newCode, verifyCode: verifyCode)
    }

    func unblockCode(_ codeType: CodeType, puk: Data, newCode: Data) async throws {
        try await usbReaderConnection.unblockCode(codeType, puk: puk, newCode: newCode)
    }
}
