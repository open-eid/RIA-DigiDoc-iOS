// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
            .onChange(of: condition) { _, newValue in
                if !newValue {
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        focusedField.wrappedValue = field
                    }
                }
            }
    }
}

extension View {
    func filePreview(item: Binding<FileItem?>) -> some View {
        self.sheet(item: item) { file in
            FilePreviewSheet(url: file.url, isPresented: Binding(
                get: { item.wrappedValue != nil },
                set: { if !$0 { item.wrappedValue = nil } }
            ))
        }
    }
}

private struct FilePreviewSheet: View {
    let url: URL
    @Binding var isPresented: Bool

    var body: some View {
        if url.isPlainText {
            TextFilePreview(url: url, isPresented: $isPresented)
        } else {
            PreviewController(url: url, isPresented: $isPresented)
        }
    }
}
