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
