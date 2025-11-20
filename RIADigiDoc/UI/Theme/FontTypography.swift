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
        .displayLarge: FontConfig(size: displayLargeSize, weight: .regular, isCondensed: true, textStyle: .largeTitle),
        .displayMedium: FontConfig(
            size: displayMediumSize,
            weight: .regular,
            isCondensed: true,
            textStyle: .largeTitle
        ),
        .displaySmall: FontConfig(size: displaySmallSize, weight: .regular, isCondensed: true, textStyle: .largeTitle),

        .headlineLarge: FontConfig(size: headlineLargeSize, weight: .regular, isCondensed: false, textStyle: .title),
        .headlineMedium: FontConfig(size: headlineMediumSize, weight: .regular, isCondensed: false, textStyle: .title2),
        .headlineSmall: FontConfig(size: headlineSmallSize, weight: .regular, isCondensed: false, textStyle: .title3),

        .titleLarge: FontConfig(size: titleLargeSize, weight: .regular, isCondensed: false, textStyle: .title3),
        .titleMedium: FontConfig(size: titleMediumSize, weight: .medium, isCondensed: false, textStyle: .headline),
        .titleSmall: FontConfig(size: titleSmallSize, weight: .medium, isCondensed: false, textStyle: .subheadline),

        .bodyLarge: FontConfig(size: bodyLargeSize, weight: .regular, isCondensed: false, textStyle: .body),
        .bodyMedium: FontConfig(size: bodyMediumSize, weight: .regular, isCondensed: false, textStyle: .body),
        .bodySmall: FontConfig(size: bodySmallSize, weight: .regular, isCondensed: false, textStyle: .callout),

        .labelLarge: FontConfig(size: labelLargeSize, weight: .medium, isCondensed: false, textStyle: .subheadline),
        .labelMedium: FontConfig(size: labelMediumSize, weight: .medium, isCondensed: false, textStyle: .footnote),
        .labelSmall: FontConfig(size: labelSmallSize, weight: .medium, isCondensed: false, textStyle: .caption)
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

extension FontTypography {
    static let labelSmallSize: CGFloat = 11
    static let labelMediumSize: CGFloat = 12
    static let labelLargeSize: CGFloat = 14

    static let bodySmallSize: CGFloat = 12
    static let bodyMediumSize: CGFloat = 14
    static let bodyLargeSize: CGFloat = 16

    static let titleSmallSize: CGFloat = 14
    static let titleMediumSize: CGFloat = 16
    static let titleLargeSize: CGFloat = 22

    static let headlineSmallSize: CGFloat = 24
    static let headlineMediumSize: CGFloat = 28
    static let headlineLargeSize: CGFloat = 32

    static let displaySmallSize: CGFloat = 36
    static let displayMediumSize: CGFloat = 45
    static let displayLargeSize: CGFloat = 57
}
