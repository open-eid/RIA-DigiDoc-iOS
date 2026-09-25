// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

enum FileLastOpenedError: Error {
    case writeFailed(errno: Int32)
    case readFailed(errno: Int32)
    case removeFailed(errno: Int32)
    case invalidData
}
