// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

public struct SupportedLanguage: Identifiable, Equatable, Hashable {
    let code: String
    let titleKey: String
    let accessibilityInputLabel: String
    public var id: String { code }
}
