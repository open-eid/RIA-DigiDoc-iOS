import SwiftUI

enum Theme: Int, CaseIterable, Identifiable {
    case system = 0
    case light = 1
    case dark = 2

    static let key = "colorScheme"
    var id: Int { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    static func getCurrentTheme() -> Theme {
        let raw = UserDefaults.standard.integer(forKey: key)
        return Theme(rawValue: raw) ?? .system
    }

    static func getCurrentColorPalette(for colorScheme: ColorScheme) -> ColorPalette {
        switch getCurrentTheme() {
        case .light: return AppColors.light
        case .dark:  return AppColors.dark
        case .system:
            return colorScheme == .dark ? AppColors.dark : AppColors.light
        }
    }
}
