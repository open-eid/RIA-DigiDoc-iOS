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

public enum Theme: Int, Sendable {
    case system = 0
    case light = 1
    case dark = 2

    static let key = "colorScheme"

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    static func getCurrentColorPalette(for colorScheme: ColorScheme, currentTheme: Theme) -> ColorPalette {
        switch currentTheme {
        case .light: return AppColors.light
        case .dark:  return AppColors.dark
        case .system:
            return colorScheme == .dark ? AppColors.dark : AppColors.light
        }
    }
}
