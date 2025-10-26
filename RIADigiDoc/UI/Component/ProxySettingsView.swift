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
import FactoryKit

struct ProxySettingsView: View {
    @AppTheme private var theme
    @AppTypography private var typography
    @EnvironmentObject private var languageSettings: LanguageSettings
    @Environment(\.dismiss) private var dismiss

    @State private var proxyOption: ProxySettingsOption = .disabled

    // TODO: This will move into viewmodel
    @State private var port: String = "70000"

    private var isPortValid: Bool {
        if port.isEmpty { return true }
        if let portInt = Int(port) {
            if 0 < portInt && portInt < 65536 {
                return true
            }
        }
        return false
    }

    var body: some View {
        TopBarContainer(
            title: languageSettings.localized("Main settings proxy title"),
            onLeftClick: { dismiss() },
            excludeDestinations: [.advanced],
            content: {
                ScrollView {
                    OutlinedRadioButtonCard(
                        title: languageSettings.localized("Main settings proxy no proxy"),
                        isSelected: proxyOption == .disabled,
                        onSelect: {
                            proxyOption = .disabled
                        }
                    )

                    OutlinedRadioButtonCard(
                        title: languageSettings.localized("Main settings proxy use system"),
                        isSelected: proxyOption == .system,
                        onSelect: {
                            proxyOption = .system
                        }
                    )

                    OutlinedRadioButtonCard(
                        title: languageSettings.localized("Main settings proxy manual"),
                        isSelected: proxyOption == .manual,
                        onSelect: {
                            proxyOption = .manual
                        },
                        contentSpacing: Dimensions.Padding.MPadding,
                        content: {
                            manualCardContent
                        }
                    )

                    Button(
                        action: {},
                        label: {
                            Text(languageSettings.localized("Main settings proxy check connection"))
                                .font(typography.labelLarge)
                                .foregroundStyle(theme.primary)
                        }
                    )
                    .padding(.vertical, Dimensions.Padding.LPadding)

                    Spacer()
                }
                .padding(.horizontal, Dimensions.Padding.SPadding)
                .padding(.vertical, Dimensions.Padding.SPadding)
            }
        )
        .background(theme.surface)
    }

    @ViewBuilder
    private var manualCardContent: some View {
        FloatingLabelTextField(
            title: languageSettings.localized("Main settings proxy host"),
            text: .constant(""),
        )
        FloatingLabelTextField(
            title: languageSettings.localized("Main settings proxy port"),
            text: $port,
            isInvalid: !isPortValid,
            invalidText: languageSettings.localized("Main settings proxy port error"),
            keyboardType: .numberPad
        )
        FloatingLabelTextField(
            title: languageSettings.localized("Main settings proxy username"),
            text: .constant(""),
        )
        FloatingLabelTextField(
            title: languageSettings.localized("Main settings proxy password"),
            text: .constant(""),
            isSecure: true
        )
    }
}

// MARK: - Preview

#Preview {
    ProxySettingsView()
        .environmentObject(Container.shared.languageSettings())
        .environmentObject(Container.shared.themeSettings())
}
