import SwiftUI

enum Theme: Int {
    case system = 0
    case light = 1
    case dark = 2

    static let key = "colorScheme"

    static func set(_ theme: Theme) {
        UserDefaults.standard.set(theme.rawValue, forKey: key)
    }

    static func currentSetting() -> Theme {
        let raw = UserDefaults.standard.integer(forKey: key)
        return Theme(rawValue: raw) ?? .system
    }

    static func palette(for colorScheme: ColorScheme) -> ColorPalette {
        switch currentSetting() {
        case .light: return AppColors.light
        case .dark: return AppColors.dark
        case .system:
            return colorScheme == .dark ? AppColors.dark : AppColors.light
        }
    }
}
