// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import CommonsLib

/// @mockable
@MainActor
public protocol RoleViewModelProtocol: Sendable {
    func saveInputData(_ roleData: RoleData) async
    func getInputData() async -> RoleData
}
