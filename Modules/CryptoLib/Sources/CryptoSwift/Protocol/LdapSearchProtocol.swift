// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import CryptoObjCWrapper

/// @mockable
public protocol LdapSearchProtocol: Sendable {
    @MainActor func search(identityCode: String) async -> LdapSearchResult
}
