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

    static let initialLaunchScreenBackground = Color(hex: 0x103064)

    static let light: ColorPalette = {
        let primary = Color(hex: 0x002048)
        let primaryContainer = Color(hex: 0x194178)
        let secondary = Color(hex: 0x535F77)
        let secondaryContainer = Color(hex: 0xD9E4FF)
        let error = Color(hex: 0xB00020)
        let errorContainer = Color(hex: 0xFFDAD6)
        let success = Color(hex: 0x0F6B38)
        let successContainer = Color(hex: 0xD6F5E3)
        let warning = Color(hex: 0x7A3E00)
        let warningContainer = Color(hex: 0xFFDEA6)

        let onPrimary = Color.white
        let onPrimaryContainer = Color(hex: 0xC5D7FF)
        let onSecondaryContainer = Color(hex: 0x3D4960)
        let onSecondary = Color.white
        let onError = Color.white
        let onErrorContainer = Color(hex: 0x410002)
        let onSuccess = Color.white
        let onSuccessContainer = Color(hex: 0x00210F)
        let onWarning = Color.white
        let onWarningContainer = Color(hex: 0x2A1400)

        let outline = Color(hex: 0x747781)
        let outlineVariant = Color(hex: 0xC3C6D1)
        let surface = Color(hex: 0xFAF9FE)
        let surfaceContainer = Color(hex: 0xEEEDF3)
        let surfaceContainerLowest = Color.white
        let surfaceContainerLow = Color(hex: 0xF4F3F8)
        let surfaceContainerHigh = Color(hex: 0xE8E7ED)
        let surfaceContainerHighest = Color(hex: 0xE2E2E7)
        let surfaceVariant = Color(hex: 0xE0E2ED)
        let onSurface = Color(hex: 0x1A1C1F)
        let onSurfaceVariant = Color(hex: 0x434750)

        let inversePrimary = Color(hex: 0xAAC7FF)
        let inverseSurface = Color(hex: 0x2F3034)
        let inverseOnSurface = Color(hex: 0xF1F0F5)

        return ColorPalette(
            primary: primary,
            primaryContainer: primaryContainer,
            secondary: secondary,
            secondaryContainer: secondaryContainer,
            error: error,
            errorContainer: errorContainer,
            success: success,
            successContainer: successContainer,
            warning: warning,
            warningContainer: warningContainer,
            onPrimary: onPrimary,
            onPrimaryContainer: onPrimaryContainer,
            onSecondaryContainer: onSecondaryContainer,
            onError: onError,
            onErrorContainer: onErrorContainer,
            onSuccess: onSuccess,
            onSuccessContainer: onSuccessContainer,
            onWarning: onWarning,
            onWarningContainer: onWarningContainer,
            outline: outline,
            outlineVariant: outlineVariant,
            surface: surface,
            surfaceContainer: surfaceContainer,
            surfaceContainerLowest: surfaceContainerLowest,
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
        let primary = Color(hex: 0xAAC7FF)
        let primaryContainer = Color(hex: 0x002958)
        let secondary = Color(hex: 0xBAC7E3)
        let secondaryContainer = Color(hex: 0x313D54)
        let error = Color(hex: 0xFF6F70)
        let errorContainer = Color(hex: 0x7A1818)
        let success = Color(hex: 0x4DD17A)
        let successContainer = Color(hex: 0x1A4D2E)
        let warning = Color(hex: 0xFFBC57)
        let warningContainer = Color(hex: 0x5A2E00)

        let onPrimary = Color(hex: 0x002F65)
        let onPrimaryContainer = Color(hex: 0x95B6F5)
        let onSecondary = Color(hex: 0x253146)
        let onSecondaryContainer = Color(hex: 0xC4D1ED)
        let onError = Color(hex: 0x690005)
        let onErrorContainer = Color(hex: 0xFFB0B0)
        let onSuccess = Color(hex: 0x00210F)
        let onSuccessContainer = Color(hex: 0xB0EEBF)
        let onWarning = Color(hex: 0x2A1400)
        let onWarningContainer = Color(hex: 0xFFC87A)

        let outline = Color(hex: 0x8D909B)
        let outlineVariant = Color(hex: 0x434750)
        let surface = Color(hex: 0x121317)
        let surfaceContainer = Color(hex: 0x1E2023)
        let surfaceContainerLowest = Color(hex: 0x0D0E12)
        let surfaceContainerLow = Color(hex: 0x1A1C1F)
        let surfaceContainerHigh = Color(hex: 0x282A2E)
        let surfaceContainerHighest = Color(hex: 0x333539)
        let surfaceVariant = Color(hex: 0x434750)
        let onSurface = Color(hex: 0xE2E2E7)
        let onSurfaceVariant = Color(hex: 0xC3C6D1)

        let inversePrimary = Color(hex: 0x3B5E97)
        let inverseSurface = Color(hex: 0xE2E2E7)
        let inverseOnSurface = Color(hex: 0x2F3034)

        return ColorPalette(
            primary: primary,
            primaryContainer: primaryContainer,
            secondary: secondary,
            secondaryContainer: secondaryContainer,
            error: error,
            errorContainer: errorContainer,
            success: success,
            successContainer: successContainer,
            warning: warning,
            warningContainer: warningContainer,
            onPrimary: onPrimary,
            onPrimaryContainer: onPrimaryContainer,
            onSecondaryContainer: onSecondaryContainer,
            onError: onError,
            onErrorContainer: onErrorContainer,
            onSuccess: onSuccess,
            onSuccessContainer: onSuccessContainer,
            onWarning: onWarning,
            onWarningContainer: onWarningContainer,
            outline: outline,
            outlineVariant: outlineVariant,
            surface: surface,
            surfaceContainer: surfaceContainer,
            surfaceContainerLowest: surfaceContainerLowest,
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
