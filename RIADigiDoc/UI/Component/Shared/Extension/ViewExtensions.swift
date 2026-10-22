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

func voiceControlInputLabels(_ input: String?, _ label: String) -> [String] {
    if let input {
        return [input, label]
    }
    return [label]
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

    func accessibilityFocusOnAppear(
        _ focus: AccessibilityFocusState<Bool>.Binding,
        trigger: String,
        enabled: Bool = true
    ) -> some View {
        modifier(AccessibilityFocusOnAppear(focus: focus, trigger: trigger, enabled: enabled))
    }
}

private struct AccessibilityFocusOnAppear: ViewModifier {
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled

    let focus: AccessibilityFocusState<Bool>.Binding
    let trigger: String
    let enabled: Bool

    @State private var hasFocused = false

    func body(content: Content) -> some View {
        content
            .accessibilityFocused(focus)
            .task(id: trigger) {
                guard enabled, voiceOverEnabled, !hasFocused, !trigger.isEmpty else { return }

                do {
                    try await Task.sleep(for: .seconds(0.3))
                } catch {
                    return
                }

                hasFocused = true
                focus.wrappedValue = true
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
