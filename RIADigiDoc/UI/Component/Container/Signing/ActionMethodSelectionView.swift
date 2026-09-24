// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
        case .decrypt:
            languageSettings.localized("Choose a method of decryption")
        case .signing:
            languageSettings.localized("Choose a signing method")
        case .myeid:
            languageSettings.localized("Identification method title")
        case .auth, .certificate, .signingWebEid:
            "" // Web eID flows never present this view
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
        case .auth, .certificate, .signingWebEid:
            "" // Web eID flows never present this view
        }
    }

    var saveButtonAccessibilityLabel: String {
        switch actionType {
        case .decrypt:
            languageSettings.localized("Decryption method changed")
        case .signing:
            languageSettings.localized("Signing method changed")
        case .myeid:
            languageSettings.localized("Identification method changed")
        case .auth, .certificate, .signingWebEid:
            "" // Web eID flows never present this view
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
                            },
                            focusedField: nil,
                            currentFocus: .constant(nil)
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
                case .decrypt:
                    selectedMethod = await viewModel.getSelectedDecryptMethod()
                case .signing:
                    selectedMethod = await viewModel.getSelectedSigningMethod()
                case .myeid:
                    selectedMethod = await viewModel.getSelectedMyEidMethod()
                case .auth, .certificate, .signingWebEid:
                    selectedMethod = .idCardViaNFC // Web eID flows never present this view
                }
            }
        }
        .onChange(of: shouldSetMethod) { _, newValue in
            if newValue {
                AccessibilityUtil.announceMessage(saveButtonAccessibilityLabel)
                setActionMethod(selectedMethod)
            }
        }
    }

    func setActionMethod(_ selectedMethod: ActionMethod) {
        Task {
            switch actionType {
            case .decrypt:
                await viewModel.setSelectedDecryptMethod(selectedMethod)
            case .signing:
                await viewModel.setSelectedSigningMethod(selectedMethod)
            case .myeid:
                await viewModel.setSelectedMyEidMethod(selectedMethod)
            case .auth:
                // Do nothing
                break
            case .certificate:
                // Do nothing
                break
            case .signingWebEid:
                // Do nothing
                break
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
            .mobileId,
            .smartId
        ]
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
    .environment(NavigationPathManager())
}
