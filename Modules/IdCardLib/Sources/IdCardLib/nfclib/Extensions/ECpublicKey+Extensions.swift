//
//  ECpublicKey+Extensions.swift
//  nfc-lib
//
//  Created by Timo Kallaste on 30.11.2023.
//

import CommonCrypto
import CryptoTokenKit
internal import SwiftECC

extension ECPublicKey {
    convenience init?(domain: Domain, point: Data) throws {
        guard let decodePoint = try? domain.decodePoint(Bytes(point)) else { return nil }
        try self.init(domain: domain, w: decodePoint)
    }

    func x963Representation() throws -> Bytes {
        return try domain.encodePoint(w)
    }
}
