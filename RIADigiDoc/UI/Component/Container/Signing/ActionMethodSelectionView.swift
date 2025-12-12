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

struct ActionMethodSelectionView: View {
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @Environment(\.dismiss) private var dismiss

    @Environment(LanguageSettings.self) private var languageSettings

    @AppTheme private var theme
    @AppTypography private var typography

    @State private var viewModel: ActionMethodSelectionViewModel

    @State private var actionType: ActionType
    @State private var selectedMethod: ActionMethod = .idCardViaNFC
    @State private var methods: [ActionMethod]

    @State private var shouldSetMethod: Bool = false

    var actionMethodTitle: String {
        switch actionType {
        case .signing:
            languageSettings.localized("Choose a signing method")
        case .myeid:
            languageSettings.localized("Identification method title")
        }
    }

    private var selectedActionMethodLabel: String {
        switch actionType {
        case .signing:
            languageSettings.localized("Signing method")
        case .myeid:
            languageSettings.localized("Identification method")
        }
    }

    var saveButtonAccessibilityLabel: String {
        switch actionType {
        case .signing:
            languageSettings.localized("Signing method changed")
        case .myeid:
            languageSettings.localized("Identification method changed")
        }
    }

    init(
        actionType: ActionType,
        methods: [ActionMethod]
    ) {
        _viewModel = State(wrappedValue: Container.shared.actionMethodSelectionViewModel())
        self.actionType = actionType
        self.methods = methods
    }

    var body: some View {
        TopBarContainer(
            title: nil,
            onLeftClick: { dismiss()
            },
            content: {
                VStack(alignment: .leading) {
                    ScrollView {
                        Text(verbatim: actionMethodTitle)
                            .font(typography.headlineSmall)
                            .foregroundStyle(theme.onSurface)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, Dimensions.Padding.SPadding)
                            .accessibilityHeading(.h1)
                            .accessibilityAddTraits([.isHeader])

                        RadioButtonChooserView<ActionMethod>(
                            options: methods,
                            isSelected: { actionMethod in
                                actionMethod == selectedMethod
                            },
                            titleKey: { actionMethod in
                                languageSettings.localized(actionMethod.rawValue)
                            },
                            onSelect: { actionMethod in
                                selectedMethod = actionMethod
                            },
                            accessibilityLabel: { actionMethod, _ in
                                let method = languageSettings.localized(actionMethod.rawValue)
                                let selected = actionMethod == selectedMethod
                                ? languageSettings.localized("Radiobutton selected")
                                : languageSettings.localized("Radiobutton unselected")
                                return "\(selectedActionMethodLabel) \(method) \(selected)"
                            }
                        )

                        PrimaryButton(
                            text: languageSettings.localized("Save selection"),
                            isButtonEnabled: true,
                            action: {
                                shouldSetMethod = true
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
                switch actionType {
                case .signing:
                    selectedMethod = await viewModel.getSelectedSigningMethod()
                case .myeid:
                    selectedMethod = await viewModel.getSelectedMyEidMethod()
                }
            }
        }
        .onChange(of: shouldSetMethod) { _, newValue in
            if newValue {
                if voiceOverEnabled {
                    var saveButtonAccessibilityAnnouncement = AttributedString(saveButtonAccessibilityLabel)
                    saveButtonAccessibilityAnnouncement.accessibilitySpeechAnnouncementPriority = .high
                    AccessibilityNotification.Announcement(saveButtonAccessibilityAnnouncement).post()
                }

                setActionMethod(selectedMethod)
            }
        }
    }

    func setActionMethod(_ selectedMethod: ActionMethod) {
        Task {
            switch actionType {
            case .signing:
                await viewModel.setSelectedSigningMethod(selectedMethod)
            case .myeid:
                await viewModel.setSelectedMyEidMethod(selectedMethod)
            }

            await MainActor.run {
                dismiss()
            }
        }
    }
}

#Preview {
    ActionMethodSelectionView(
        actionType: .signing,
        methods: [
            .idCardViaNFC,
            .idCardViaUSB,
            .mobileId,
            .smartId
        ]
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
