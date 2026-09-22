// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import UIKit

struct TextFilePreview: View {
    @Environment(LanguageSettings.self) private var languageSettings

    @AppTheme private var theme
    @AppTypography private var typography

    let url: URL
    @Binding var isPresented: Bool
    @State private var text: String = ""
    @State private var showError: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text(verbatim: url.lastPathComponent)
                    .font(typography.bodyMedium)
                    .foregroundStyle(theme.onSurfaceVariant)
                    .frame(maxWidth: .infinity, alignment: .center)

                HStack {
                    Spacer()
                    Button {
                        isPresented = false
                    } label: {
                        Image("ic_m3_close_48pt_wght400")
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: Dimensions.Icon.IconSizeXXS,
                                height: Dimensions.Icon.IconSizeXXS
                            )
                            .padding(.horizontal, Dimensions.Padding.MPadding)
                            .padding(.vertical, Dimensions.Padding.MSPadding)
                            .foregroundStyle(theme.onSurface)
                            .accessibilityLabel(languageSettings.localized("Close"))
                    }
                    .keyboardShortcut(.escape, modifiers: [])
                    .padding(Dimensions.Padding.XSPadding)
                }
            }

            if showError {
                ContentUnavailableView {
                    Text(
                        verbatim: languageSettings.localized(
                            "Failed to open file", [url.lastPathComponent]
                        )
                    )
                }
                .listRowSeparator(.hidden)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                SelectableTextView(
                    text: text,
                    font: FontTypography.uiFont(for: .bodyMedium),
                    textColor: UIColor(theme.onSurfaceVariant),
                    insets: UIEdgeInsets(
                        top: Dimensions.Padding.SPadding,
                        left: Dimensions.Padding.SPadding,
                        bottom: Dimensions.Padding.XXLPadding,
                        right: Dimensions.Padding.SPadding
                    )
                )
            }
        }
        .task {
            do {
                var detectedEncoding: String.Encoding = .utf8
                text = try String(contentsOfFile: url.path, usedEncoding: &detectedEncoding)
            } catch {
                self.showError = true
            }
        }
    }
}

private struct SelectableTextView: UIViewRepresentable {
    let text: String
    let font: UIFont
    let textColor: UIColor
    let insets: UIEdgeInsets

    func makeUIView(context _: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = .clear
        textView.alwaysBounceVertical = true
        textView.adjustsFontForContentSizeCategory = true
        textView.textContainerInset = insets
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }

    func updateUIView(_ uiView: UITextView, context _: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        uiView.font = font
        uiView.textColor = textColor
        uiView.textContainerInset = insets
    }
}
