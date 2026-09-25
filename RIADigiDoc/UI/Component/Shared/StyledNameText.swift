// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import UtilsLib

struct StyledNameText: View {
    @AppTheme private var theme
    @AppTypography private var typography

    let name: String
    var allCaps: Bool = false

    var body: some View {
        let finalName = allCaps ? name.uppercased() : name
        let nameParts = finalName.components(separatedBy: ", ").map { $0.trimmingCharacters(in: .whitespaces) }

        Group {
            if nameParts.count == 2 {
                (Text(nameParts[0]).fontWeight(.bold) +
                 Text(verbatim: ", ").fontWeight(.regular) +
                 Text(nameParts[1]).fontWeight(.regular))
            } else {
                Text(finalName)
                    .fontWeight(.bold)
            }
        }
        .foregroundStyle(theme.onSurface)
        .font(typography.bodyLarge)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
