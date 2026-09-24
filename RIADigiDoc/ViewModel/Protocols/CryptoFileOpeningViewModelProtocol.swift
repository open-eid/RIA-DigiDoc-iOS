// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

/// @mockable
@MainActor
public protocol CryptoFileOpeningViewModelProtocol: Sendable {
    func handleFiles() async
    func showFileAddedMessage() async -> Bool
    func addedFilesCount() -> Int
    func handleError() async
}
