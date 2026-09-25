// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public struct SmartIdInputData: Sendable, Equatable {
    let country: SmartIdCountry
    let personalCode: String
    let rememberMe: Bool
}
