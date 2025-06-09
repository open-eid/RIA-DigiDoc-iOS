import SwiftUI

@propertyWrapper
struct AppTypography: DynamicProperty {
    @Environment(\.typography) private var typography
    var wrappedValue: Typography { typography }
}
