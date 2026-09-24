// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import CryptoObjCWrapper

public struct OpenLdapSearchResult: Sendable {
    public var addressees: [Addressee]
    public var tooManyResults: Bool
}
