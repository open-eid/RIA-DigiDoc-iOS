// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public struct NFCInputData: Sendable {
    let canNumber: String
    let rememberMe: Bool
}
