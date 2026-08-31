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

import SwiftUI

enum AppColors {

    static let initialLaunchScreenBackground = Color(hex: 0x003168)

    static let light: ColorPalette = {
        let primary = Color(hex: 0x003168)
        let primaryContainer = Color(hex: 0xDDE8F3)
        let secondary = Color(hex: 0x747781)
        let secondaryContainer = Color(hex: 0xE2E2E7)
        let error = Color(hex: 0xB00020)
        let errorContainer = Color(hex: 0xF6DBE0)
        let success = Color(hex: 0x2FB631)
        let successContainer = Color(hex: 0xE0F4E0)
        let warning = Color(hex: 0x7A3E00)
        let warningContainer = Color(hex: 0xFAE7C9)

        let onPrimary = Color.white
        let onPrimaryContainer = Color(hex: 0x0C2246)
        let onSecondary = Color.white
        let onSecondaryContainer = Color(hex: 0x282A2E)
        let onError = Color.white
        let onErrorContainer = Color(hex: 0x710015)
        let onSuccess = Color.white
        let onSuccessContainer = Color(hex: 0x144C15)
        let onWarning = Color.white
        let onWarningContainer = Color(hex: 0x5A2E00)

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
        let inverseOnSurface = Color(hex: 0xF4F3F8)

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
            onSecondary: onSecondary,
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
        let primaryContainer = Color(hex: 0x0F2C5A)
        let secondary = Color(hex: 0xE0E2ED)
        let secondaryContainer = Color(hex: 0x2F3034)
        let error = Color(hex: 0xFF5C79)
        let errorContainer = Color(hex: 0x50000F)
        let success = Color(hex: 0x74CE75)
        let successContainer = Color(hex: 0x0C2E0C)
        let warning = Color(hex: 0xFBAE38)
        let warningContainer = Color(hex: 0x5A2E00)

        let onPrimary = Color(hex: 0x0C2246)
        let onPrimaryContainer = Color(hex: 0xB5BFCF)
        let onSecondary = Color(hex: 0x2F3034)
        let onSecondaryContainer = Color(hex: 0xFAF9FE)
        let onError = Color(hex: 0x34000A)
        let onErrorContainer = Color(hex: 0xEFCCD2)
        let onSuccess = Color(hex: 0x144C15)
        let onSuccessContainer = Color(hex: 0x74CE75)
        let onWarning = Color(hex: 0x5A2E00)
        let onWarningContainer = Color(hex: 0xF2C174)

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

        let inversePrimary = Color(hex: 0x003168)
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
            onSecondary: onSecondary,
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
