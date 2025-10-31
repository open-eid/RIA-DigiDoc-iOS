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

    @Binding var isSigningEnabled: Bool
    @Binding var isSigning: Bool
    let onBackClick: () -> Void
    let onSign: () -> Void
    let content: Content

    init(
        isSigningEnabled: Binding<Bool>,
        isSigning: Binding<Bool>,
        onBackClick: @escaping () -> Void,
        onSign: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
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

                        if !isSigning {
                            VStack(alignment: .leading, spacing: Dimensions.Padding.SPadding) {
                                Text(verbatim: languageSettings.localized("Signing method"))
                                    .font(typography.labelLarge)
                                    .foregroundStyle(theme.onSurfaceVariant)

                                NavigationLink(destination: SigningMethodSelectionView()) {
                                    HStack {
                                        // TODO: Replace with actual chosen signing method
                                        Text(verbatim: languageSettings.localized("Mobile-ID"))
                                            .font(typography.bodyLarge)
                                            .foregroundStyle(theme.onSurface)
                                        Spacer()
                                        Image("ic_m3_arrow_right_48pt_wght400")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(
                                                width: Dimensions.Icon.IconSizeXXS,
                                                height: Dimensions.Icon.IconSizeXXS
                                            )
                                            .foregroundStyle(theme.onBackground)
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
        isSigningEnabled: .constant(true),
        isSigning: .constant(false),
        onBackClick: {},
        onSign: {},
        content: {}
    )
    .environmentObject(Container.shared.languageSettings())
    .environmentObject(Container.shared.themeSettings())
}
