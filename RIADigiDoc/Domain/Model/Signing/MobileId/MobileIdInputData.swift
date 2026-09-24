// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public struct MobileIdInputData: Sendable {
    let phoneNumber: String
    let personalCode: String
    let rememberMe: Bool
}
