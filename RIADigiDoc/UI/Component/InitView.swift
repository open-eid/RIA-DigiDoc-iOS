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

struct InitView: View {
    @AppTypography private var typography
    @EnvironmentObject private var languageSettings: LanguageSettings

    @StateObject private var viewModel: InitViewModel

    @State private var navigateToContent = false

    private let supportedLanguages: [SupportedLanguage] = [
        SupportedLanguage(code: "et", titleKey: "Init lang locale et", accessibilityInputLabel: "Estonian"),
        SupportedLanguage(code: "en", titleKey: "Init lang locale en", accessibilityInputLabel: "English")
    ]
    private var appName: String {
        languageSettings.localized("App name")
    }

    init() {
        _viewModel = StateObject(wrappedValue: Container.shared.initViewModel())
    }

    var body: some View {
        ZStack {
            AppColors.BlueBackground.ignoresSafeArea()
            GeometryReader { geometry in
                ScrollView {
                    VStack(
                        spacing: Dimensions.Padding.ZeroPadding
                    ) {
                        Image("image_eesti_shield")
                            .resizable()
                            .scaledToFit()
                            .frame(height: Dimensions.Icon.IconSizeXXL)
                            .padding(.top, Dimensions.Padding.LPadding)
                            .accessibilityLabel(appName.lowercased())

                        Text(appName.uppercased())
                            .font(typography.headlineMedium)
                            .foregroundStyle(Color.white)
                            .padding(.bottom, Dimensions.Padding.LPadding)
                            .accessibilityLabel(appName.lowercased())

                        LanguageButtonChooserView<SupportedLanguage>(
                            options: supportedLanguages,
                            titleKey: { languageOption in languageOption.titleKey },
                            onTap: { languageOption in
                                Task {
                                    await viewModel.selectLanguage(code: languageOption.code)
                                    navigateToContent = true
                                }
                            },
                            accessibilityLabel: { languageOption in
                                languageSettings.localized(languageOption.titleKey)
                            },
                            accessibilityInputLabel: { languageOption in
                                languageOption.accessibilityInputLabel
                            }
                        )
                        .padding(.vertical, Dimensions.Padding.MPadding)

                        Spacer()

                        Text(languageSettings.localized("RIA small caps"))
                            .font(typography.titleMedium)
                            .foregroundStyle(Color.white)
                            .padding(.bottom, Dimensions.Padding.MPadding)
                            .accessibilityLabel("Riigi Infosüsteemide Amet")

                        NavigationLink(
                            destination: ContentView(),
                            isActive: $navigateToContent
                        ) { EmptyView() }
                            .hidden()
                    }
                    .frame(minHeight: geometry.size.height)
                    .frame(minWidth: geometry.size.width)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    InitView()
        .environmentObject(Container.shared.languageSettings())
}
