// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

extension CharacterSet {
    static var forbiddenInFileName: CharacterSet {
        var forbidden = CharacterSet.controlCharacters
        forbidden.insert(charactersIn: "/\\<>:\"|?*")
        forbidden.remove(charactersIn: "\u{200D}")
        return forbidden
    }
}
