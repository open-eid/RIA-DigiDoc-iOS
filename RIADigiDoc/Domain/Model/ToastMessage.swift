// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

struct ToastMessage: Sendable, Equatable {
    let key: String
    let args: [String]

    init(key: String, args: [String] = []) {
        self.key = key
        self.args = args
    }
}
