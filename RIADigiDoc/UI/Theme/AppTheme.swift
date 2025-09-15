import SwiftUI

@MainActor
@propertyWrapper
struct AppTheme: DynamicProperty {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var themeSettings: ThemeSettings

    var wrappedValue: ColorPalette {
        Theme.getCurrentColorPalette(for: colorScheme, currentTheme: themeSettings.getSelectedTheme())
    }
}
