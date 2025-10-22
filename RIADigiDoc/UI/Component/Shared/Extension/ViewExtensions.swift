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
