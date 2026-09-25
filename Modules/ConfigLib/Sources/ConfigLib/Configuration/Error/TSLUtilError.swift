// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

enum TSLUtilError: Error {
    case fileListError(message: String)
    case sequenceNumberError(message: String)
}
