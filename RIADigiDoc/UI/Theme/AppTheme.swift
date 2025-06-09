import SwiftUI

@propertyWrapper
struct AppTheme: DynamicProperty {
    @Environment(\.colorScheme) private var colorScheme

    var wrappedValue: ColorPalette {
        Theme.palette(for: colorScheme)
    }
}
