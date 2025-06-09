import SwiftUI

enum AppColors {

    static let light: ColorPalette = {
        let primary = Color(hex: 0xFF002048)
        let primaryContainer = Color(hex: 0xFF194178)
        let secondaryContainer = Color(hex: 0xFFD9E4FF)
        let tertiary = Color(hex: 0xFF300e41)
        let tertiaryContainer = Color(hex: 0xFF533166)
        let error = Color(hex: 0xFFBA1A1A)
        let errorContainer = Color(hex: 0xFFFFDAD6)

        let onPrimary = Color.white
        let onPrimaryContainer = Color(hex: 0xFFC5D7FF)
        let onSecondaryContainer = Color(hex: 0xFF3D4960)
        let onTertiary = Color.white
        let onTertiaryContainer = Color(hex: 0xFFF3C7FF)
        let onError = Color.white
        let onErrorContainer = Color(hex: 0xFF410002)

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
            onPrimary: onPrimary,
            onPrimaryContainer: onPrimaryContainer,
            onSecondaryContainer: onSecondaryContainer,
            onTertiary: onTertiary,
            onTertiaryContainer: onTertiaryContainer,
            onError: onError,
            onErrorContainer: onErrorContainer,
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
        let error = Color(hex: 0xFFFFB4AB)
        let errorContainer = Color(hex: 0xFF93000A)

        let background = Color.black
        let onBackground = Color.white

        let onPrimary = Color(hex: 0xFF002F65)
        let onPrimaryContainer = Color(hex: 0xFF95B6F5)
        let onSecondaryContainer = Color(hex: 0xFFC4D1ED)
        let onTertiary = Color(hex: 0xFF471E57)
        let onTertiaryContainer = Color(hex: 0xFFD7A4E6)
        let onError = Color(hex: 0xFF690005)
        let onErrorContainer = Color(hex: 0xFFFFDAD6)

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
            onPrimary: onPrimary,
            onPrimaryContainer: onPrimaryContainer,
            onSecondaryContainer: onSecondaryContainer,
            onTertiary: onTertiary,
            onTertiaryContainer: onTertiaryContainer,
            onError: onError,
            onErrorContainer: onErrorContainer,
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
