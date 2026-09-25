// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

enum PersonalCodeError: Error {
    case invalidPersonalCode(String)
    case invalidDate(String)
}
