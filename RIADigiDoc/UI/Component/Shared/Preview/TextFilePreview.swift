/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
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
