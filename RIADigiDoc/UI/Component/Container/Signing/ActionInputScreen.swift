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
import FactoryKit

struct ActionInputScreen<Content: View>: View {
    @AppTheme private var theme
    @AppTypography private var typography

    @Environment(LanguageSettings.self) private var languageSettings

    private let selectedActionMethod: ActionMethod

    @State private var actionType: ActionType
    @State private var actionMethods: [ActionMethod]
    @Binding var isActionEnabled: Bool
    @Binding var isInProgress: Bool
    let showSubmitButton: Bool
    let onBackClick: () -> Void
    let onSubmit: () -> Void
    let content: Content

    private var headerTitle: String {
        switch actionType {
        case .decrypt:
            languageSettings.localized("Container decryption")
        case .signing:
            languageSettings.localized("Container signing")
        case .myeid:
            languageSettings.localized("Identification title")
        case .auth:
            languageSettings.localized("Authentication title")
        case .certificate:
            languageSettings.localized("Certificate title")
        case .signingWebEid:
            languageSettings.localized("Container signing")
        }
    }

    private var selectedActionMethodLabel: String {
        switch actionType {
        case .decrypt:
            languageSettings.localized("Decryption method")
        case .signing:
            languageSettings.localized("Signing method")
        case .myeid:
            languageSettings.localized("Identification method")
        case .auth:
            languageSettings.localized("Authentication method")
        case .certificate:
            languageSettings.localized("Certificate method")
        case .signingWebEid:
            languageSettings.localized("Signing method")
        }
    }

    private var selectedSigningMethodText: String {
        languageSettings.localized(selectedActionMethod.rawValue)
    }

    private var buttonTitle: String {
        switch actionType {
        case .decrypt:
            languageSettings.localized("Decrypt")
        case .signing:
            languageSettings.localized("Sign")
        case .myeid:
            languageSettings.localized("Identify")
        case .auth:
            languageSettings.localized("Authenticate")
        case .certificate:
            languageSettings.localized("Confirm")
        case .signingWebEid:
            languageSettings.localized("Sign")
        }
    }

    init(
        actionType: ActionType = .signing,
        actionMethods: [ActionMethod] = [
            .idCardViaNFC,
            .idCardViaUSB,
            .mobileId,
            .smartId
        ],
        selectedActionMethod: ActionMethod,
        isActionEnabled: Binding<Bool>,
        isInProgress: Binding<Bool>,
        showSubmitButton: Bool = true,
        onBackClick: @escaping () -> Void,
        onSubmit: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.actionType = actionType
        self.actionMethods = actionMethods
        self.selectedActionMethod = selectedActionMethod
        self._isActionEnabled = isActionEnabled
        self._isInProgress = isInProgress
        self.showSubmitButton = showSubmitButton
        self.onBackClick = onBackClick
        self.onSubmit = onSubmit
        self.content = content()
    }

    var body: some View {
        TopBarContainer(
            title: nil,
            showNavigationIcon: (actionType == .signingWebEid
                                 || actionType == .certificate
                                 || actionType == .auth
                                ) ? false : true,
            onLeftClick: onBackClick,
            showRightIcons: !isInProgress,
            content: {
                VStack(alignment: .leading) {
                    ScrollView {
                        Text(verbatim: headerTitle)
                            .font(typography.headlineSmall)
                            .foregroundStyle(theme.onSurface)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, Dimensions.Padding.SPadding)
                            .accessibilityHeading(.h1)
                            .accessibilityAddTraits([.isHeader])

                        if !isInProgress {
                            if actionMethods.count > 1 {
                                VStack(alignment: .leading, spacing: Dimensions.Padding.SPadding) {
                                    Text(verbatim: selectedActionMethodLabel)
                                        .font(typography.labelLarge)
                                        .foregroundStyle(theme.onSurfaceVariant)
                                        .accessibilityHidden(true)

                                    NavigationLink(
                                        value: NavigationDestination.signingMethodSelectionView(
                                            actionType: actionType,
                                            methods: actionMethods
                                        )
                                    ) {
                                        HStack {
                                            Text(verbatim: selectedSigningMethodText)
                                                .font(typography.bodyLarge)
                                                .foregroundStyle(theme.onSurface)
                                                .accessibilityLabel(Text(verbatim:
                                                    "\(selectedActionMethodLabel) \(selectedSigningMethodText)")
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
                        }

                        content

                        // ID-card via USB shows the button later in the process
                        if (!isInProgress ||
                            selectedActionMethod == .idCardViaUSB
                        ) && showSubmitButton {
                            PrimaryButton(
                                text: buttonTitle,
                                isButtonEnabled: isActionEnabled,
                                action: onSubmit,
                                focusedField: nil,
                                currentFocus: .constant(nil)
                            )
                            .padding(.vertical, Dimensions.Padding.MPadding)
                        }

                        if actionType == .signingWebEid || actionType == .auth || actionType == .certificate {
                            PrimaryButton(
                                text: languageSettings.localized("Cancel"),
                                isButtonEnabled: true,
                                action: onBackClick,
                                focusedField: nil,
                                currentFocus: .constant(nil)
                            )
                        }
                    }
                }
                .padding(.horizontal, Dimensions.Padding.SPadding)
            }
        )
    }
}

#Preview {
    ActionInputScreen(
        actionType: .signing,
        selectedActionMethod: .idCardViaNFC,
        isActionEnabled: .constant(true),
        isInProgress: .constant(false),
        onBackClick: {},
        onSubmit: {},
        content: {}
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
