// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit

struct SigningServicesSettingsView: View {
    @AppTheme private var theme
    @AppTypography private var typography

    @Environment(LanguageSettings.self) private var languageSettings
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTab: SigningServicesSettingsViewTab = .timestampServices

    @State private var showSettingsBottomSheetFromButton = false

    var body: some View {
        TopBarContainer(
            title: languageSettings.localized("Main settings signing services title"),
            onLeftClick: { dismiss() },
            excludeDestinations: [.advanced],
            content: {
                ScrollView {
                    VStack(spacing: Dimensions.Padding.ZeroPadding) {
                        TabView(
                            selectedTab: $selectedTab,
                            titles: [
                                languageSettings.localized("Main settings timestamp services title"),
                                languageSettings.localized("Main settings mobile id and smart id title"),
                                languageSettings.localized("Main settings lta tab title")
                            ],
                            content: {
                                if selectedTab == .timestampServices {
                                    TimeStampSettingsView()
                                        .padding(.horizontal, Dimensions.Padding.SPadding)
                                } else if selectedTab == .mobileIdAndSmartId {
                                    MobileIDSmartIDSettingsView()
                                        .padding(.horizontal, Dimensions.Padding.SPadding)
                                } else {
                                    LTASettingsView()
                                        .padding(.horizontal, Dimensions.Padding.SPadding)
                                }
                            }
                        )
                        .padding(.top, Dimensions.Padding.MPadding)
                    }
                }
            }
        )
    }
}

// MARK: - Preview

#Preview {
    SigningServicesSettingsView()
        .environment(Container.shared.languageSettings())
        .environment(Container.shared.themeSettings())
        .environment(NavigationPathManager())
}
