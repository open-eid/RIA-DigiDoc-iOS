// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import CryptoObjCWrapper

public struct OpenLdapSearchResult: Sendable {
    public var addressees: [Addressee]
    public var tooManyResults: Bool
    public var isNetworkError: Bool

    public init(addressees: [Addressee], tooManyResults: Bool, isNetworkError: Bool = false) {
        self.addressees = addressees
        self.tooManyResults = tooManyResults
        self.isNetworkError = isNetworkError
    }
}
