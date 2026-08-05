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
import UtilsLib
import CommonsLib
import CryptoObjCWrapper

struct EncryptRecipientView: View {
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageSettings.self) private var languageSettings

    @Environment(NavigationPathManager.self) private var pathManager

    @AppTheme private var theme
    @AppTypography private var typography

    @AccessibilityFocusState private var isTitleFocused: Bool
    @AccessibilityFocusState private var isSearchFieldFocused: Bool
    @AccessibilityFocusState private var focusedRecipientIndex: Int?
    @FocusState private var isSearchFocused: Bool
    @State private var isSearchExpanded = false

    @State private var encryptionButtonEnabled = true

    @State private var showNoRecipientsFoundMessage = false

    @State private var selectedRecipient: Addressee?
    @State private var showRemoveRecipientModal = false
    @State private var showPasswordEncryptModal = false

    @State private var addedRecipients: [Addressee] = []
    @State private var selectedTab: EncryptRecipientViewTab = .recipient
    @State private var cdocOption: EncryptionCdocOption

    @State private var viewModel: EncryptRecipientViewModel
    @State private var encryptViewModel: EncryptViewModel

    init(cdocOption: EncryptionCdocOption) {
        _cdocOption = State(wrappedValue: cdocOption)
        _viewModel = State(wrappedValue: Container.shared.encryptRecipientViewModel())
        _encryptViewModel = State(wrappedValue: Container.shared.encryptViewModel())
    }

    var filteredRecipients: [Addressee] {
        viewModel.filteredRecipients()
    }

    var noRecipients: Bool {
        filteredRecipients.isEmpty
    }

    var noSearchResults: Bool {
        viewModel.searchText.isEmpty
    }

    var encryptLabel: String {
        languageSettings.localized("Encrypt")
    }

    var nextLabel: String {
        languageSettings.localized("Next")
    }

    var noSearchResultsMessage: String {
        languageSettings.localized("Person or company does not own a valid certificate")
    }

    private var recipientTabTitle: String {
        languageSettings.localized("Encrypt based on recipient")
    }

    private var passwordTabTitle: String {
        languageSettings.localized("Encrypt with password")
    }

    private var addedRecipientsSection: some View {
        VStack(alignment: .leading, spacing: Dimensions.Padding.ZeroPadding) {
            if noSearchResults {
                Text(verbatim: languageSettings.localized("Added recipients"))
                    .accessibilityHeading(.h2)
                    .accessibilityAddTraits([.isHeader])
            } else {
                Text(verbatim: languageSettings.localized("Recently added"))
                    .accessibilityHeading(.h2)
                    .accessibilityAddTraits([.isHeader])
            }

            Spacer().frame(height: Dimensions.Padding.MSPadding)

            if #available(iOS 26.0, *) {
                ForEach(addedRecipients.enumerated(), id: \.offset) { index, item in
                    addedRecipientRow(index: index, item: item)
                }
            } else {
                ForEach(Array(addedRecipients.enumerated()), id: \.offset) { index, item in
                    addedRecipientRow(index: index, item: item)
                }
            }
        }
        .padding(.horizontal, Dimensions.Padding.SPadding)
        .listStyle(.plain)
        .scrollDisabled(true)
        .scrollContentBackground(.hidden)
        .listRowSpacing(0)
        .listSectionSpacing(.compact)
    }

    private var filteredRecipientsSection: some View {
        VStack {
            if #available(iOS 26.0, *) {
                ForEach(filteredRecipients.enumerated(), id: \.offset) { index, item in
                    recipientRow(index: index, item: item)
                }
            } else {
                ForEach(Array(filteredRecipients.enumerated()), id: \.offset) { index, item in
                    recipientRow(index: index, item: item)
                }
            }
        }
        .listStyle(.plain)
        .scrollDisabled(true)
        .scrollContentBackground(.hidden)
        .listRowSpacing(0)
        .listSectionSpacing(.compact)
    }

    @ViewBuilder
    private var bottomButtonBar: some View {
        if cdocOption == .cdoc2 && selectedTab == .password {
            UnsignedBottomBarView(
                showLeftButton: false,
                leftButtonIconName: "",
                leftButtonLabel: "",
                leftButtonAccessibilityLabel: "",
                leftButtonAction: {},
                rightButtonEnabled: true,
                rightButtonIconName: "ic_m3_arrow_forward_48pt_wght400",
                rightButtonLabel: nextLabel,
                rightButtonAccessibilityLabel: nextLabel.lowercased(),
                rightButtonAction: {
                    showPasswordEncryptModal = true
                },
                showBackground: false
            )
            .accessibilityIdentifier("bottomNextButton")
        } else {
            HStack {
                Spacer()
                Button(action: {
                    encryptionButtonEnabled = false
                    pathManager.replaceLast(
                        to: .encryptView(isWithEncryption: true, cdocOption: cdocOption, selectedTab: .files)
                    )
                }, label: {
                    HStack(spacing: Dimensions.Padding.XSPadding) {
                        Image("ic_m3_encrypted_48pt_wght400")
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: Dimensions.Icon.IconSizeXXS,
                                height: Dimensions.Icon.IconSizeXXS
                            )
                            .foregroundStyle(theme.onPrimaryContainer)
                        Text(verbatim: encryptLabel)
                            .foregroundStyle(theme.onPrimaryContainer)
                            .font(typography.bodyLarge)
                    }
                    .accessibilityHidden(true)
                })
                .contentShape(Rectangle())
                .disabled(!encryptionButtonEnabled)
                .padding(Dimensions.Padding.MSPadding)
                .background(
                    RoundedRectangle(cornerRadius: Dimensions.Corner.MSCornerRadius)
                        .fill(theme.primaryContainer)
                        .shadow(
                            color: theme.onSurfaceVariant.opacity(Dimensions.Shadow.SOpacity),
                            radius: Dimensions.Shadow.radius,
                            x: Dimensions.Shadow.xOffset,
                            y: Dimensions.Shadow.yOffset
                        )
                )
                .padding(Dimensions.Padding.MPadding)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(encryptLabel.lowercased())
                .accessibilityAddTraits(.isButton)
                .accessibilityIdentifier("bottomEncryptButton")
            }
        }
    }

    @ViewBuilder
    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(theme.onSurfaceVariant)
                .accessibilityHidden(true)

            FloatingLabelTextField(
                title: "",
                placeholder: languageSettings.localized("Search recipients"),
                text: $viewModel.searchText,
                submitLabel: .done,
                identifier: "searchRecipients",
                sortPriority: 1,
                showBorder: false,
                onDone: {
                    if viewModel.searchText.allSatisfy(\.isNumber) &&
                        viewModel.searchText.count == 11 &&
                        !PersonalCodeValidator.isPersonalCodeValid(viewModel.searchText) {
                        let personalCodeNotValidMessage = languageSettings.localized(
                            "Personal code is not valid"
                        )

                        Toast.show(personalCodeNotValidMessage)

                        if voiceOverEnabled {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                AccessibilityUtil.announceMessage(
                                    personalCodeNotValidMessage
                                )
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    isTitleFocused = true
                                }
                            }
                        }
                        return
                    }

                    Task {
                        await viewModel.loadRecipients()
                    }
                }
            )
            .accessibilityFocused($isSearchFieldFocused)
            .focused($isSearchFocused)
            .onChange(of: isSearchFocused) { _, newValue in
                isSearchExpanded = newValue
            }
            .onChange(of: viewModel.searchText) {
                viewModel.handleSearchTextChange()
            }
        }
        .padding(.horizontal, Dimensions.Padding.SPadding)
        .background(
            RoundedRectangle(cornerRadius: Dimensions.Padding.MPadding, style: .continuous)
                .fill(Color(.systemGray6))
        )
    }

    @ViewBuilder
    private var recipientsScrollView: some View {
        ScrollView {
            if noSearchResults && !isSearchExpanded {
                VStack {
                    Text(languageSettings.localized("Crypto recipients description"))
                        .font(typography.bodyLarge)
                        .foregroundStyle(theme.onSurfaceVariant)
                        .multilineTextAlignment(.leading)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .scrollDisabled(true)
                .scrollContentBackground(.hidden)
            } else if showNoRecipientsFoundMessage {
                emptyStateView(
                    languageSettings.localized(
                        "Person or company does not own a valid certificate"
                    )
                )
            } else {
                filteredRecipientsSection
            }

            Spacer().frame(height: Dimensions.Padding.MSPadding)

            if addedRecipients.count > 0 {
                addedRecipientsSection
            }
        }
        .accessibilitySortPriority(filteredRecipients.isEmpty ? 2 : 0)
    }

    @ViewBuilder
    private func containerRecipientsTitle(topPadding: CGFloat) -> some View {
        if !isSearchExpanded {
            Text(verbatim: languageSettings.localized("Container recipients"))
                .foregroundStyle(theme.onSurface)
                .font(typography.headlineSmall)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, topPadding)
                .minimumScaleFactor(0.5)
                .accessibilityHeading(.h1)
                .accessibilityAddTraits([.isHeader])
                .accessibilityFocused($isTitleFocused)
                .accessibilitySortPriority(3)
                .onAppear {
                    if noSearchResults { isTitleFocused = true }
                }
        }
    }

    var body: some View {
        TopBarContainer(
            title: nil,
            onLeftClick: {
                pathManager.replaceLast(
                    to: .encryptView(isWithEncryption: false, cdocOption: cdocOption, selectedTab: .files)
                )
            },
            showRightIcons: !isSearchExpanded,
            content: {
                ZStack {
                    VStack(alignment: .leading, spacing: Dimensions.Padding.ZeroPadding) {
                        if cdocOption == .cdoc2 {
                            TabView(selectedTab: $selectedTab, titles: [
                                recipientTabTitle,
                                passwordTabTitle
                            ]) {
                                if selectedTab == .recipient {
                                    VStack(alignment: .leading, spacing: Dimensions.Padding.ZeroPadding) {
                                        containerRecipientsTitle(topPadding: Dimensions.Padding.MPadding)
                                        searchField
                                            .padding(.top, Dimensions.Padding.SPadding)
                                            .padding(.bottom, Dimensions.Padding.SPadding)
                                        recipientsScrollView
                                    }
                                } else {
                                    VStack(alignment: .leading, spacing: Dimensions.Padding.ZeroPadding) {
                                        ScrollView {
                                            Text(languageSettings.localized("Crypto password encryption description"))
                                                .font(typography.bodyLarge)
                                                .foregroundStyle(theme.onSurfaceVariant)
                                                .multilineTextAlignment(.leading)
                                                .padding(.top, Dimensions.Padding.MPadding)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                }
                            }
                        } else {
                            containerRecipientsTitle(topPadding: Dimensions.Padding.SPadding)
                            searchField
                                .padding(.top, Dimensions.Padding.LPadding)
                                .padding(.bottom, Dimensions.Padding.SPadding)
                            recipientsScrollView
                        }

                        bottomButtonBar
                    }
                    .padding(.horizontal, Dimensions.Padding.SPadding)
                    .accessibilityElement(children: .contain)

                    if showPasswordEncryptModal {
                        EncryptPasswordModalView(
                            onEncrypt: { _, _, _ in
                                showPasswordEncryptModal = false
                                pathManager.replaceLast(
                                    to: .encryptView(
                                        isWithEncryption: false,
                                        cdocOption: cdocOption,
                                        selectedTab: .recipients
                                    )
                                )
                            },
                            onCancel: {
                                showPasswordEncryptModal = false
                            }
                        )
                    }

                    if showRemoveRecipientModal {
                        ConfirmModalView(
                            title: "\(languageSettings.localized("Remove recipient"))?",
                            message: languageSettings.localized("Remove recipient from container"),
                            onConfirm: {
                                guard let recipient = selectedRecipient else {
                                    Toast.show(languageSettings.localized("Failed to remove recipient"))
                                    return
                                }
                                Task {
                                    await viewModel.deleteRecipient(recipient)
                                    addedRecipients = await viewModel.filteredAddedRecipients()
                                    selectedRecipient = nil
                                    showRemoveRecipientModal = false
                                    await viewModel.loadRecipients()
                                }
                            },
                            onCancel: {
                                selectedRecipient = nil
                                showRemoveRecipientModal = false
                            }
                        )
                    }
                }
                .onAppear {
                    Task { @MainActor in
                        await viewModel.loadRecipients()
                        addedRecipients = await viewModel.filteredAddedRecipients()
                    }
                }
                .onChange(of: viewModel.searchText) { _, _ in
                    showNoRecipientsFoundMessage = false
                }
                .onChange(of: viewModel.errorMessage) { _, error in
                    guard let error, !error.key.isEmpty else { return }

                    isTitleFocused = false

                    let localizedMessage = languageSettings.localized(error.key, [error.args.joined(separator: ", ")])
                    Toast.show(localizedMessage)

                    if voiceOverEnabled {
                        AccessibilityUtil.announceMessage(localizedMessage)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isTitleFocused = true

                        }
                    }

                    encryptionButtonEnabled = true

                    viewModel.resetErrorMessage()
                }
                .onChange(of: viewModel.successMessage) { _, message in
                    guard let message, !message.key.isEmpty else { return }
                    let localizedMessage = languageSettings.localized(
                        message.key,
                        [message.args.joined(separator: ", ")]
                    )
                    Toast.show(localizedMessage, type: .success)

                    if voiceOverEnabled {
                        AccessibilityUtil.announceMessage(localizedMessage)
                    }

                    encryptionButtonEnabled = true

                    viewModel.resetSuccessMessage()
                }
            }
        )
    }

    private func recipientRow(index: Int, item: Addressee) -> some View {
        RecipientsView(
            recipient: item,
            recipientIndex: index,
            showRemoveButton: false,
            onOpenRecipient: {
                Task { @MainActor in
                    await viewModel.addRecipients(item)
                    addedRecipients = await viewModel.filteredAddedRecipients()
                }
            },
            onRemoveRecipient: {
                // do nothing
            }
        )
        .padding(.vertical, Dimensions.Padding.SPadding)
        .listRowInsets(EdgeInsets())
        .contentShape(Rectangle())
        .buttonStyle(.plain)
        .background(theme.surface)
        .accessibilityFocused($focusedRecipientIndex, equals: index)
    }

    private func addedRecipientRow(index: Int, item: Addressee) -> some View {
        RecipientsView(
            recipient: item,
            recipientIndex: index,
            showRemoveButton: true,
            onOpenRecipient: {
                pathManager
                    .navigate(
                        to: .recipientDetailView(
                            recipient: item
                        )
                    )
            },
            onRemoveRecipient: {
                selectedRecipient = item
                showRemoveRecipientModal = true
            }
        )
        .padding(.vertical, Dimensions.Padding.SPadding)
        .listRowInsets(EdgeInsets())
        .contentShape(Rectangle())
        .buttonStyle(.plain)
        .background(theme.surface)
    }

    private func emptyStateView(_ text: String) -> some View {
        ContentUnavailableView {
            Text(verbatim: text)
                .font(typography.bodyLarge)
                .foregroundStyle(theme.onSurfaceVariant)
        }
        .listRowSeparator(.hidden)
    }
}

#Preview {
    EncryptRecipientView(cdocOption: .cdoc1)
        .environment(Container.shared.languageSettings())
        .environment(Container.shared.themeSettings())
        .environment(NavigationPathManager())
}
