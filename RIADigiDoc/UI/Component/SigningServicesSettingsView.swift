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

struct SigningServicesSettingsView: View {
    @AppTheme private var theme
    @AppTypography private var typography

    @EnvironmentObject private var languageSettings: LanguageSettings
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTab: SigningServicesSettingsViewTab = .timestampServices

    @State private var showSettingsBottomSheetFromButton = false

    var body: some View {
        TopBarContainer(
            title: languageSettings.localized("Main settings signing services title"),
            onLeftClick: { dismiss() },
            onRightSecondaryClick: {
                showSettingsBottomSheetFromButton = true
            },
            excludeDestinations: [.advanced],
            content: {
                ScrollView {
                    VStack(spacing: Dimensions.Padding.ZeroPadding) {
                        TabView(
                            selectedTab: $selectedTab,
                            titles: [
                                languageSettings.localized("Main settings timestamp services title"),
                                languageSettings.localized("Main settings mobile id and smart id title")
                            ],
                            content: {
                                if selectedTab == .timestampServices {
                                    TimeStampSettingsView()
                                        .padding(.horizontal, Dimensions.Padding.SPadding)
                                } else {
                                    MobileIDSmartIDSettingsView()
                                        .padding(.horizontal, Dimensions.Padding.SPadding)
                                }
                            }
                        )
                    }
                }
            }
        )
    }
}

// MARK: - Preview

#Preview {
    SigningServicesSettingsView()
        .environmentObject(Container.shared.languageSettings())
        .environmentObject(Container.shared.themeSettings())
}
