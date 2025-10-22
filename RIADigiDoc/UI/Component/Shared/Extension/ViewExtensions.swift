import SwiftUI

func accessibleAction<Field: Hashable>(
    voiceOverEnabled: Bool,
    focusedField: AccessibilityFocusState<Field?>.Binding,
    delay: TimeInterval = 0.5,
    action: @escaping () -> Void
) -> () -> Void {
    return {
        if voiceOverEnabled {
            focusedField.wrappedValue = nil

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                action()
            }
        } else {
            action()
        }
    }
}

extension View {
    func accessibilityFocusRestore<Field: Hashable>(
        focusedField: AccessibilityFocusState<Field?>.Binding,
        field: Field,
        delay: TimeInterval = 0.5,
        when condition: Bool = true
    ) -> some View {
        self
            .accessibilityFocused(focusedField, equals: field)
            .onChange(of: condition) { newValue in
                if !newValue {
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        focusedField.wrappedValue = field
                    }
                }
            }
    }
}
