// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

/// @mockable
@MainActor
public protocol ActionMethodSelectionViewModelProtocol: Sendable {
    func setSelectedSigningMethod(_ method: ActionMethod) async
    func getSelectedSigningMethod() async -> ActionMethod

    func setSelectedMyEidMethod(_ method: ActionMethod) async
    func getSelectedMyEidMethod() async -> ActionMethod
}
