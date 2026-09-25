// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import CommonsLib
import Foundation

/// @mockable
public protocol TSLUtilProtocol: Sendable {
    func setupTSLFiles(
        tsls: [String],
        destinationDir: URL,
    ) throws

    func readSequenceNumber(from inputStreamURL: URL) throws -> Int
}
