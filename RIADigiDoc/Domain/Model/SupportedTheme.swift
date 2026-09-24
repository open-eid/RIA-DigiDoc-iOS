// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

struct SupportedTheme: Identifiable, Equatable, Hashable {
    let themeKey: Theme
    let titleKey: String
    var id: Theme { themeKey }
}
