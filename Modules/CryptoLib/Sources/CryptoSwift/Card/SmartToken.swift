// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
