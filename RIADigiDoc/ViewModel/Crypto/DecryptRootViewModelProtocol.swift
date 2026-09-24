// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

/// @mockable
@MainActor
public protocol DecryptRootViewModelProtocol: Sendable {
    func getSelectedDecryptMethod() async -> ActionMethod
}
