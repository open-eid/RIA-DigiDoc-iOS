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
    let textStyle: Font.TextStyle
}

struct FontTypography {
    private static let fontConfigs: [AppTextStyle: FontConfig] = [
        .displayLarge: FontConfig(size: 57, weight: .regular, isCondensed: true, textStyle: .largeTitle),
        .displayMedium: FontConfig(size: 45, weight: .regular, isCondensed: true, textStyle: .largeTitle),
        .displaySmall: FontConfig(size: 36, weight: .regular, isCondensed: true, textStyle: .largeTitle),

        .headlineLarge: FontConfig(size: 32, weight: .regular, isCondensed: false, textStyle: .title),
        .headlineMedium: FontConfig(size: 28, weight: .regular, isCondensed: false, textStyle: .title2),
        .headlineSmall: FontConfig(size: 24, weight: .regular, isCondensed: false, textStyle: .title3),

        .titleLarge: FontConfig(size: 22, weight: .regular, isCondensed: false, textStyle: .title3),
        .titleMedium: FontConfig(size: 16, weight: .medium, isCondensed: false, textStyle: .headline),
        .titleSmall: FontConfig(size: 14, weight: .medium, isCondensed: false, textStyle: .subheadline),

        .bodyLarge: FontConfig(size: 16, weight: .regular, isCondensed: false, textStyle: .body),
        .bodyMedium: FontConfig(size: 14, weight: .regular, isCondensed: false, textStyle: .body),
        .bodySmall: FontConfig(size: 12, weight: .regular, isCondensed: false, textStyle: .callout),

        .labelLarge: FontConfig(size: 14, weight: .medium, isCondensed: false, textStyle: .subheadline),
        .labelMedium: FontConfig(size: 12, weight: .medium, isCondensed: false, textStyle: .footnote),
        .labelSmall: FontConfig(size: 11, weight: .medium, isCondensed: false, textStyle: .caption)
    ]

    static func font(for style: AppTextStyle) -> Font {
        let config = fontConfig(for: style)
        let fontName = fontName(forCondensed: config.isCondensed, weight: config.weight)

        // Use relativeTo parameter for Dynamic Type support
        return .custom(fontName, size: config.size, relativeTo: config.textStyle)
    }

    private static func fontConfig(for style: AppTextStyle) -> FontConfig {
        return fontConfigs[style] ?? FontConfig(size: 14, weight: .regular, isCondensed: false, textStyle: .body)
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
