// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI

struct TextFilePreview: View {
    @Environment(LanguageSettings.self) private var languageSettings

    @AppTheme private var theme
    @AppTypography private var typography

    let url: URL
    @Binding var isPresented: Bool
    @State private var text: String = ""
    @State private var showError: Bool = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if showError {
                    ContentUnavailableView {
                        Text(
                            verbatim: languageSettings.localized(
                                "Failed to open file", [url.lastPathComponent]
                            )
                        )
                    }
                    .listRowSeparator(.hidden)
                } else {
                    ScrollView {
                        Text(verbatim: text)
                            .font(typography.bodyMedium)
                            .foregroundStyle(theme.onSurfaceVariant)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, Dimensions.Padding.SPadding)
                            .padding(.vertical, Dimensions.Padding.XXLPadding)
                            .textSelection(.enabled)
                    }
                }
            }

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
