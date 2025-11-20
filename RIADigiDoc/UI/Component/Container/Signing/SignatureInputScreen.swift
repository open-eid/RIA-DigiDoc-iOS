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

struct SignatureInputScreen<Content: View>: View {
    @AppTheme private var theme
    @AppTypography private var typography

    @EnvironmentObject private var languageSettings: LanguageSettings

    private let selectedSigningMethod: String

    @Binding var isSigningEnabled: Bool
    @Binding var isSigning: Bool
    let onBackClick: () -> Void
    let onSign: () -> Void
    let content: Content

    private var selectedSigningMethodLabel: String {
        languageSettings.localized("Signing method")
    }

    private var selectedSigningMethodText: String {
        languageSettings.localized(selectedSigningMethod)
    }

    init(
        selectedSigningMethod: String,
        isSigningEnabled: Binding<Bool>,
        isSigning: Binding<Bool>,
        onBackClick: @escaping () -> Void,
        onSign: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.selectedSigningMethod = selectedSigningMethod
        self._isSigningEnabled = isSigningEnabled
        self._isSigning = isSigning
        self.onBackClick = onBackClick
        self.onSign = onSign
        self.content = content()
    }

    var body: some View {
        TopBarContainer(
            title: nil,
            onLeftClick: onBackClick,
            showRightIcons: !isSigning,
            content: {
                VStack(alignment: .leading) {
                    ScrollView {
                        Text(verbatim: languageSettings.localized("Container signing"))
                            .font(typography.headlineSmall)
                            .foregroundStyle(theme.onSurface)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, Dimensions.Padding.SPadding)
                            .accessibilityHeading(.h1)
                            .accessibilityAddTraits([.isHeader])

                        if !isSigning {
                            VStack(alignment: .leading, spacing: Dimensions.Padding.SPadding) {
                                Text(verbatim: selectedSigningMethodLabel)
                                    .font(typography.labelLarge)
                                    .foregroundStyle(theme.onSurfaceVariant)
                                    .accessibilityHidden(true)

                                NavigationLink(destination: SigningMethodSelectionView()) {
                                    HStack {
                                        Text(verbatim: selectedSigningMethodText)
                                            .font(typography.bodyLarge)
                                            .foregroundStyle(theme.onSurface)
                                            .accessibilityLabel(Text(verbatim:
                                                "\(selectedSigningMethodLabel) \(selectedSigningMethodText)")
                                            )
                                        Spacer()
                                        Image("ic_m3_arrow_right_48pt_wght400")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(
                                                width: Dimensions.Icon.IconSizeXXS,
                                                height: Dimensions.Icon.IconSizeXXS
                                            )
                                            .foregroundStyle(theme.onBackground)
                                            .accessibilityHidden(true)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, Dimensions.Padding.SPadding)
                            .padding(.bottom, Dimensions.Padding.MPadding)
                        }

                        content

                        if !isSigning {
                            PrimaryButton(
                                text: languageSettings.localized("Sign"),
                                isButtonEnabled: isSigningEnabled,
                                action: onSign
                            )
                            .padding(.vertical, Dimensions.Padding.MPadding)
                        }
                    }
                }
                .padding(.horizontal, Dimensions.Padding.SPadding)
            }
        )
    }
}

#Preview {
    SignatureInputScreen(
        selectedSigningMethod: "ID-card via NFC",
        isSigningEnabled: .constant(true),
        isSigning: .constant(false),
        onBackClick: {},
        onSign: {},
        content: {}
    )
    .environmentObject(Container.shared.languageSettings())
    .environmentObject(Container.shared.themeSettings())
}
