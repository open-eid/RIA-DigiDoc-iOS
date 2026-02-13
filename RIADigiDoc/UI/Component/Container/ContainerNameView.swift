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

import FactoryKit
import SwiftUI

struct ContainerNameView: View {
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @Environment(LanguageSettings.self) private var languageSettings
    @AppTheme private var theme
    @AppTypography private var typography

    @State private var showBottomSheetFromButton = false
    @State private var showBottomSheetFromTap = false
    @State private var tempContainerURL: URL?
    @State private var isShowingFileSaver = false
    @State private var isFileSaved: Bool = false

    @AccessibilityFocusState private var focusedField: AccessibilityField?

    let icon: String
    let containerNameTitle: String
    @Binding var name: String
    let isEditContainerButtonShown: Bool
    let isSaveButtonShown: Bool
    let isSignButtonShown: Bool
    let isEncryptButtonShown: Bool
    let showLeftActionButton: Bool
    let showRightActionButton: Bool
    let leftActionButtonName: String
    let rightActionButtonName: String
    let leftActionButtonAccessibilityLabel: String
    let rightActionButtonAccessibilityLabel: String
    let onLeftActionButtonClick: () -> Void
    let onRightActionButtonClick: () -> Void
    let onSaveContainerButtonClick: () -> Void
    let onRenameContainerButtonClick: () -> Void
    let onSignContainerButtonClick: () -> Void
    let onEncryptContainerButtonClick: () -> Void

    private var bottomSheetActions: [BottomSheetButton] {
        ContainerNameBottomSheetActions.actions(
            isEditContainerButtonShown: isEditContainerButtonShown,
            isSaveButtonShown: isSaveButtonShown,
            isSignButtonShown: isSignButtonShown,
            isEncryptButtonShown: isEncryptButtonShown,
            onRenameContainerButtonClick: onRenameContainerButtonClick,
            onSaveContainerButtonClick: onSaveContainerButtonClick,
            onSignContainerButtonClick: onSignContainerButtonClick,
            onEncryptContainerButtonClick: onEncryptContainerButtonClick
        )
    }

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: Dimensions.Padding.XSPadding) {
                HStack(alignment: .center) {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(theme.onPrimary)
                        .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                        .padding(Dimensions.Padding.XSPadding)
                        .background(theme.primary)
                        .clipShape(Circle())
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: Dimensions.Padding.ZeroPadding) {
                        Text(languageSettings.localized(containerNameTitle))
                            .font(typography.labelMedium)
                            .foregroundStyle(theme.onSurface)
                        HStack {
                            Text(name)
                                .font(typography.titleMedium)
                                .foregroundStyle(theme.onSurface)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(2)
                                .truncationMode(.middle)
                                .multilineTextAlignment(TextAlignment.leading)
                        }
                    }
                    .accessibilityElement(children: .combine)

                    Spacer()

                    Button(action: accessibleAction(
                        voiceOverEnabled: voiceOverEnabled,
                        focusedField: $focusedField
                    ) {
                        showBottomSheetFromButton = true
                    }, label: {
                        Image("ic_m3_more_vert_48pt_wght400")
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: Dimensions.Icon.IconSizeXXS,
                                height: Dimensions.Icon.IconSizeXXS
                            )
                            .foregroundStyle(theme.onBackground)
                    })
                    .accessibilityFocusRestore(
                        focusedField: $focusedField,
                        field: .container(.openContainerOptionsButton),
                        when: showBottomSheetFromButton
                    )
                    .accessibilityLabel(languageSettings.localized("More options"))
                    .bottomSheet(isPresented: $showBottomSheetFromButton, actions: bottomSheetActions)
                }

                if showLeftActionButton || showRightActionButton {
                    HStack {
                        Spacer()

                        if showLeftActionButton {
                            Button(languageSettings.localized(leftActionButtonName)) {
                                onLeftActionButtonClick()
                            }
                            .font(typography.labelLarge)
                            .foregroundStyle(theme.primary)
                            .accessibilityLabel(leftActionButtonAccessibilityLabel)
                        }

                        if showRightActionButton {
                            Button(languageSettings.localized(rightActionButtonName)) {
                                onRightActionButtonClick()
                            }
                            .font(typography.labelLarge)
                            .foregroundStyle(theme.primary)
                            .accessibilityLabel(rightActionButtonAccessibilityLabel)
                        }
                    }
                    .padding(.trailing, Dimensions.Padding.MSPadding)
                    .padding(.top, Dimensions.Padding.MSPadding)
                }
            }
            .padding(.horizontal, Dimensions.Padding.MSPadding)
            .padding(.vertical, Dimensions.Padding.MPadding)
            .background(theme.surfaceContainerHighest)
            .cornerRadius(Dimensions.Corner.MSCornerRadius)
            .padding(.top, Dimensions.Padding.MSPadding)
            .bottomSheet(isPresented: $showBottomSheetFromTap, actions: bottomSheetActions)
        }
    }
}

#Preview {
    ContainerNameView(
        icon: "ic_m3_stylus_note_48pt_wght400",
        containerNameTitle: "Container name",
        name: .constant("Test.asice"),
        isEditContainerButtonShown: true,
        isSaveButtonShown: true,
        isSignButtonShown: true,
        isEncryptButtonShown: false,
        showLeftActionButton: true,
        showRightActionButton: true,
        leftActionButtonName: "Sign",
        rightActionButtonName: "Encrypt",
        leftActionButtonAccessibilityLabel: "Sign container",
        rightActionButtonAccessibilityLabel: "Encrypt container",
        onLeftActionButtonClick: {},
        onRightActionButtonClick: {},
        onSaveContainerButtonClick: {},
        onRenameContainerButtonClick: {},
        onSignContainerButtonClick: {},
        onEncryptContainerButtonClick: {}
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
