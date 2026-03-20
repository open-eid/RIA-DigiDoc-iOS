/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
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

import Foundation

struct BottomSheetButton: Identifiable {
    let id = UUID()
    let showButton: Bool
    let icon: String
    let title: String
    let accessibilityLabel: String
    let showExtraIcon: Bool
    let extraIcon: String
    let onClick: () -> Void

    init(showButton: Bool = true,
         icon: String,
         title: String,
         accessibilityLabel: String,
         showExtraIcon: Bool = false,
         extraIcon: String = "ic_m3_arrow_right_48pt_wght400",
         onClick: @escaping () -> Void) {
        self.showButton = showButton
        self.icon = icon
        self.title = title
        self.accessibilityLabel = accessibilityLabel
        self.showExtraIcon = showExtraIcon
        self.extraIcon = extraIcon
        self.onClick = onClick
    }
}
