// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public enum FileOpeningMethod: Int, Sendable {
    case all = 0
    case signing = 1
    case crypto = 2
}
