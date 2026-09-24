// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit

struct InitView: View {
    @AppTypography private var typography
    @Environment(LanguageSettings.self) private var languageSettings
    @Environment(NavigationPathManager.self) private var pathManager

    @State private var viewModel: InitViewModel

    private var appName: String {
        languageSettings.localized("App name")
    }
    private var footerRIA: String {
        languageSettings.localized("Init footer RIA")
    }

    init() {
        _viewModel = State(wrappedValue: Container.shared.initViewModel())
    }

    var body: some View {
        ZStack {
            AppColors.initialLaunchScreenBackground.ignoresSafeArea()
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
                            options: languageSettings.supportedLanguages,
                            titleKey: { languageOption in languageOption.titleKey },
                            onTap: { languageOption in
                                Task {
                                    await viewModel.selectLanguage(code: languageOption.code)
                                    pathManager.popToRoot()
                                    pathManager.navigate(to: .contentView)
                                }
                            },
                            accessibilityLabel: { languageOption in
                                languageSettings.localized(languageOption.titleKey)
                            },
                            accessibilityInputLabel: { languageOption in
                                let inputLabel = languageOption.accessibilityInputLabel
                                let title = languageSettings.localized(languageOption.titleKey)
                                if inputLabel == title { return nil }
                                return inputLabel
                            }
                        )
                        .padding(.vertical, Dimensions.Padding.MPadding)

                        Spacer()
                        smallCapsTextView(
                            footerRIA,
                            accessibilityLabel: footerRIA
                        )
                    }
                    .frame(minHeight: geometry.size.height)
                    .frame(minWidth: geometry.size.width)
                }
            }
        }
    }

    func smallCapsTextView(_ text: String, accessibilityLabel: String) -> some View {
        var attr = AttributedString(text)
        var isStartOfWord = true

        for index in attr.characters.indices {
            let char = attr.characters[index]

            let nextIndex = attr.characters.index(after: index)
            let range = index..<nextIndex

            if char.isWhitespace {
                isStartOfWord = true
                continue
            }

            if isStartOfWord {
                attr[range].font = typography.titleMedium
                isStartOfWord = false
            } else {
                attr[range].font = typography.titleMedium.smallCaps()
            }
        }

        return Text(attr)
            .foregroundColor(.white)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(accessibilityLabel)
    }
}

// MARK: - Preview
#Preview {
    InitView()
        .environment(Container.shared.languageSettings())
}
