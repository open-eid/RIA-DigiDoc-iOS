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
import nfclib
import CryptoObjCWrapper

public class SmartToken: AbstractSmartToken, @unchecked Sendable {
    let pin1: SecureData
    let card: CardCommands

    public init(card: CardCommands, pin1: SecureData) {
        self.card = card
        self.pin1 = pin1
    }

    public func getCertificate() async throws -> Data {
        return try await self.card.readAuthenticationCertificate()
    }

    public func decrypt(_ data: Data) async throws -> Data {
        return try await self.card.decryptData(data, withPin1: self.pin1)
    }

    public func derive(_ data: Data) async throws -> Data {
        return try await self.card.decryptData(data, withPin1: self.pin1)
    }

    public func authenticate(_ data: Data) async throws -> Data {
        return try await self.card.authenticate(for: data, withPin1: self.pin1)
    }
}
