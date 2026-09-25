// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

/// @mockable
@MainActor
public protocol MyEidRootViewModelProtocol: Sendable {
    func getSelectedMyEidMethod() async -> ActionMethod
}
