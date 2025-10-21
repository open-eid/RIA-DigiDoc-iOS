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

enum AppTextStyle {
    case displayLarge, displayMedium, displaySmall
    case headlineLarge, headlineMedium, headlineSmall
    case titleLarge, titleMedium, titleSmall
    case bodyLarge, bodyMedium, bodySmall
    case labelLarge, labelMedium, labelSmall
}

private struct FontConfig {
    let size: CGFloat
    let weight: Font.Weight
    let isCondensed: Bool
}

struct FontTypography {
    private static let fontConfigs: [AppTextStyle: FontConfig] = [
        .displayLarge: FontConfig(size: 57, weight: .regular, isCondensed: true),
        .displayMedium: FontConfig(size: 45, weight: .regular, isCondensed: true),
        .displaySmall: FontConfig(size: 36, weight: .regular, isCondensed: true),

        .headlineLarge: FontConfig(size: 32, weight: .regular, isCondensed: false),
        .headlineMedium: FontConfig(size: 28, weight: .regular, isCondensed: false),
        .headlineSmall: FontConfig(size: 24, weight: .regular, isCondensed: false),

        .titleLarge: FontConfig(size: 22, weight: .regular, isCondensed: false),
        .titleMedium: FontConfig(size: 16, weight: .medium, isCondensed: false),
        .titleSmall: FontConfig(size: 14, weight: .medium, isCondensed: false),

        .bodyLarge: FontConfig(size: 16, weight: .regular, isCondensed: false),
        .bodyMedium: FontConfig(size: 14, weight: .regular, isCondensed: false),
        .bodySmall: FontConfig(size: 12, weight: .regular, isCondensed: false),

        .labelLarge: FontConfig(size: 14, weight: .medium, isCondensed: false),
        .labelMedium: FontConfig(size: 12, weight: .medium, isCondensed: false),
        .labelSmall: FontConfig(size: 11, weight: .medium, isCondensed: false)
    ]

    static func font(for style: AppTextStyle) -> Font {
        let config = fontConfig(for: style)
        let fontName = fontName(forCondensed: config.isCondensed, weight: config.weight)

        guard let uiFont = UIFont(name: fontName, size: config.size) else {
            return Font.system(size: config.size, weight: config.weight)
        }

        let scaledFont = UIFontMetrics.default.scaledFont(for: uiFont)
        return Font(scaledFont)
    }

    private static func fontConfig(for style: AppTextStyle) -> FontConfig {
        return fontConfigs[style] ?? FontConfig(size: 14, weight: .regular, isCondensed: false)
    }

    private static func fontName(forCondensed: Bool, weight: Font.Weight) -> String {
        let weightName: String = {
            switch weight {
            case .light: return "Light"
            case .regular: return "Regular"
            case .medium: return "Medium"
            case .semibold: return "SemiBold"
            case .bold: return "Bold"
            default: return "Regular"
            }
        }()
        return forCondensed ? "RobotoCondensed-\(weightName)" : "Roboto-\(weightName)"
    }
}
