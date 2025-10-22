/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

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
