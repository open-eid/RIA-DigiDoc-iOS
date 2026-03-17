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

enum AppColors {

    static let BlueBackground = Color(hex: 0xFF003168)

    static let light: ColorPalette = {
        let primary = Color(hex: 0xFF002048)
        let primaryContainer = Color(hex: 0xFF194178)
        let secondaryContainer = Color(hex: 0xFFD9E4FF)
        let tertiary = Color(hex: 0xFF300e41)
        let tertiaryContainer = Color(hex: 0xFF533166)
        let error = Color(hex: 0xB00020)
        let errorContainer = Color(hex: 0xFFDAD6)
        let success = Color(hex: 0x0F6B38)
        let successContainer = Color(hex: 0xD6F5E3)
        let warning = Color(hex: 0x7A3E00)
        let warningContainer = Color(hex: 0xFFDEA6)

        let onPrimary = Color.white
        let onPrimaryContainer = Color(hex: 0xFFC5D7FF)
        let onSecondaryContainer = Color(hex: 0xFF3D4960)
        let onTertiary = Color.white
        let onTertiaryContainer = Color(hex: 0xFFF3C7FF)
        let onError = Color.white
        let onErrorContainer = Color(hex: 0x410002)
        let onSuccess = Color.white
        let onSuccessContainer = Color(hex: 0x00210F)
        let onWarning = Color.white
        let onWarningContainer = Color(hex: 0x2A1400)

        let background = Color.white
        let onBackground = Color.black

        let outline = Color(hex: 0xFF747781)
        let outlineVariant = Color(hex: 0xFFC3C6D1)
        let surface = Color(hex: 0xFFFAF9FE)
        let surfaceContainer = Color(hex: 0xFFEEEDF3)
        let surfaceContainerLow = Color(hex: 0xFFF4F3F8)
        let surfaceContainerHigh = Color(hex: 0xFFE8E7ED)
        let surfaceContainerHighest = Color(hex: 0xFFE2E2E7)
        let surfaceVariant = Color(hex: 0xFFEEEDF3)
        let onSurface = Color(hex: 0xFF1A1C1F)
        let onSurfaceVariant = Color(hex: 0xFF434750)

        let inversePrimary = Color(hex: 0xFFAAC7FF)
        let inverseSurface = Color(hex: 0xFF2F3034)
        let inverseOnSurface = Color(hex: 0xFFF1F0F5)

        return ColorPalette(
            primary: primary,
            primaryContainer: primaryContainer,
            secondaryContainer: secondaryContainer,
            tertiary: tertiary,
            tertiaryContainer: tertiaryContainer,
            error: error,
            errorContainer: errorContainer,
            success: success,
            successContainer: successContainer,
            warning: warning,
            warningContainer: warningContainer,
            onPrimary: onPrimary,
            onPrimaryContainer: onPrimaryContainer,
            onSecondaryContainer: onSecondaryContainer,
            onTertiary: onTertiary,
            onTertiaryContainer: onTertiaryContainer,
            onError: onError,
            onErrorContainer: onErrorContainer,
            onSuccess: onSuccess,
            onSuccessContainer: onSuccessContainer,
            onWarning: onWarning,
            onWarningContainer: onWarningContainer,
            background: background,
            onBackground: onBackground,
            outline: outline,
            outlineVariant: outlineVariant,
            surface: surface,
            surfaceContainer: surfaceContainer,
            surfaceContainerLow: surfaceContainerLow,
            surfaceContainerHigh: surfaceContainerHigh,
            surfaceContainerHighest: surfaceContainerHighest,
            surfaceVariant: surfaceVariant,
            onSurface: onSurface,
            onSurfaceVariant: onSurfaceVariant,
            inversePrimary: inversePrimary,
            inverseSurface: inverseSurface,
            inverseOnSurface: inverseOnSurface
        )
    }()

    static let dark: ColorPalette = {
        let primary = Color(hex: 0xFFAAC7FF)
        let primaryContainer = Color(hex: 0xFF002958)
        let secondaryContainer = Color(hex: 0xFF313D54)
        let tertiary = Color(hex: 0xFFE8B4F8)
        let tertiaryContainer = Color(hex: 0xFF401750)
        let error = Color(hex: 0xFF6F70)
        let errorContainer = Color(hex: 0x7A1818)
        let success = Color(hex: 0x4DD17A)
        let successContainer = Color(hex: 0x1A4D2E)
        let warning = Color(hex: 0xFFBC57)
        let warningContainer = Color(hex: 0x5A2E00)

        let background = Color.black
        let onBackground = Color.white

        let onPrimary = Color(hex: 0xFF002F65)
        let onPrimaryContainer = Color(hex: 0xFF95B6F5)
        let onSecondaryContainer = Color(hex: 0xFFC4D1ED)
        let onTertiary = Color(hex: 0xFF471E57)
        let onTertiaryContainer = Color(hex: 0xFFD7A4E6)
        let onError = Color(hex: 0x690005)
        let onErrorContainer = Color(hex: 0xFFB0B0)
        let onSuccess = Color(hex: 0x00210F)
        let onSuccessContainer = Color(hex: 0xB0EEBF)
        let onWarning = Color(hex: 0x2A1400)
        let onWarningContainer = Color(hex: 0xFFC87A)

        let outline = Color(hex: 0xFF8D909B)
        let outlineVariant = Color(hex: 0xFF434750)
        let surface = Color(hex: 0xFF121317)
        let surfaceContainer = Color(hex: 0xFF1E2023)
        let surfaceContainerLow = Color(hex: 0xFF1A1C1F)
        let surfaceContainerHigh = Color(hex: 0xFF282A2E)
        let surfaceContainerHighest = Color(hex: 0xFF333539)
        let surfaceVariant = Color(hex: 0xFF1E2023)
        let onSurface = Color(hex: 0xFFE2E2E7)
        let onSurfaceVariant = Color(hex: 0xFFC3C6D1)

        let inversePrimary = Color(hex: 0xFF3B5E97)
        let inverseSurface = Color(hex: 0xFFE2E2E7)
        let inverseOnSurface = Color(hex: 0xFF2F3034)

        return ColorPalette(
            primary: primary,
            primaryContainer: primaryContainer,
            secondaryContainer: secondaryContainer,
            tertiary: tertiary,
            tertiaryContainer: tertiaryContainer,
            error: error,
            errorContainer: errorContainer,
            success: success,
            successContainer: successContainer,
            warning: warning,
            warningContainer: warningContainer,
            onPrimary: onPrimary,
            onPrimaryContainer: onPrimaryContainer,
            onSecondaryContainer: onSecondaryContainer,
            onTertiary: onTertiary,
            onTertiaryContainer: onTertiaryContainer,
            onError: onError,
            onErrorContainer: onErrorContainer,
            onSuccess: onSuccess,
            onSuccessContainer: onSuccessContainer,
            onWarning: onWarning,
            onWarningContainer: onWarningContainer,
            background: background,
            onBackground: onBackground,
            outline: outline,
            outlineVariant: outlineVariant,
            surface: surface,
            surfaceContainer: surfaceContainer,
            surfaceContainerLow: surfaceContainerLow,
            surfaceContainerHigh: surfaceContainerHigh,
            surfaceContainerHighest: surfaceContainerHighest,
            surfaceVariant: surfaceVariant,
            onSurface: onSurface,
            onSurfaceVariant: onSurfaceVariant,
            inversePrimary: inversePrimary,
            inverseSurface: inverseSurface,
            inverseOnSurface: inverseOnSurface
        )
    }()
}

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255
        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }
}
