// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

/// @mockable
@MainActor
public protocol InitViewModelProtocol: Sendable {
    func selectLanguage(code: String) async
}
