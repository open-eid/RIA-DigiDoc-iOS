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

struct SigningMethodSelectionView: View {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var languageSettings: LanguageSettings

    @AppTheme private var theme
    @AppTypography private var typography

    @StateObject private var viewModel: SigningMethodSelectionViewModel

    @State private var selectedSigningMethod: SigningMethod = .idCardViaNFC

    init() {
        _viewModel = StateObject(wrappedValue: Container.shared.signingMethodSelectionViewModel())
    }

    var body: some View {
        TopBarContainer(
            title: nil,
            onLeftClick: { dismiss() },
            content: {
                VStack(alignment: .leading) {
                    ScrollView {
                        Text(verbatim: languageSettings.localized("Choose a signing method"))
                            .font(typography.headlineSmall)
                            .foregroundStyle(theme.onSurface)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, Dimensions.Padding.SPadding)

                        RadioButtonChooserView<SigningMethod>(
                            options: [
                                .idCardViaNFC,
                                .idCardViaUSB,
                                .mobileId,
                                .smartId
                            ],
                            isSelected: { signingMethod in
                                signingMethod == selectedSigningMethod
                            },
                            titleKey: { signingMethod in
                                languageSettings.localized(signingMethod.rawValue)
                            },
                            onSelect: { signingMethod in
                                selectedSigningMethod = signingMethod
                            },
                            accessibilityLabel: { _, _ in "" }
                        )

                        PrimaryButton(
                            text: languageSettings.localized("Save selection"),
                            isButtonEnabled: true,
                            action: {
                                Task {
                                    await viewModel.setSelectedSigningMethod(
                                        selectedSigningMethod
                                    )

                                    await MainActor.run {
                                        dismiss()
                                    }
                                }
                            }
                        )
                        .padding(.vertical, Dimensions.Padding.MPadding)
                    }
                }
                .padding(.horizontal, Dimensions.Padding.SPadding)
            }
        )
        .onAppear {
            Task {
                selectedSigningMethod = await viewModel.getSelectedSigningMethod()
            }
        }
    }
}

#Preview {
    SigningMethodSelectionView()
        .environmentObject(Container.shared.languageSettings())
        .environmentObject(Container.shared.themeSettings())
}
