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
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageSettings.self) private var languageSettings

    @Environment(NavigationPathManager.self) private var pathManager

    @AppTheme private var theme
    @AppTypography private var typography

    @FocusState private var isSearchFocused: Bool
    @State private var isSearchExpanded = false

    @State private var encryptionButtonEnabled = true

    @State private var showNoRecipientsFoundMessage = false

    @State private var selectedRecipient: Addressee?
    @State private var showRemoveRecipientModal = false

    @State private var addedRecipients: [Addressee] = []

    @State private var viewModel: EncryptRecipientViewModel
    @State private var encryptViewModel: EncryptViewModel

    init() {
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
    
    var noSearchResultsMessage: String {
        languageSettings.localized("Person or company does not own a valid certificate")
    }
    
    private var addedRecipientsSection: some View {
        VStack(alignment: .leading, spacing: Dimensions.Padding.ZeroPadding) {
            if noSearchResults {
                Text(verbatim: languageSettings.localized("Added recipients"))
            } else {
                Text(verbatim: languageSettings.localized("Recently added"))
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

    var body: some View {
        TopBarContainer(
            title: nil,
            onLeftClick: {
                pathManager.replaceLast(to: .encryptView(isWithEncryption: false))
            },
            showRightIcons: !isSearchExpanded,
            content: {
                ZStack {
                    VStack(alignment: .leading, spacing: Dimensions.Padding.ZeroPadding) {
                        if !isSearchExpanded {
                            Text(verbatim: languageSettings.localized("Container recipients"))
                                .foregroundStyle(theme.onSurface)
                                .font(typography.headlineSmall)
                                .padding(.top, Dimensions.Padding.SPadding)
                                .accessibilityHeading(.h1)
                                .accessibilityAddTraits([.isHeader])
                        }
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(theme.onSurfaceVariant)
                                .accessibilityHidden(true)

                            TextField(
                                languageSettings.localized("Search recipients"),
                                text: $viewModel.searchText
                            )
                            .submitLabel(.done)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .focused($isSearchFocused)
                            .onChange(of: isSearchFocused) {  _, newValue in
                                isSearchExpanded = newValue
                            }
                            .onChange(of: viewModel.searchText) {
                                viewModel.handleSearchTextChange()
                            }
                            .onSubmit {
                                if viewModel.searchText.allSatisfy(\.isNumber) &&
                                    viewModel.searchText.count == 11 &&
                                    !PersonalCodeValidator.isPersonalCodeValid(viewModel.searchText) {
                                    Toast.show(languageSettings.localized("Personal code is not valid"))
                                    return
                                }

                                Task {
                                    await viewModel.loadRecipients()

                                    if noRecipients {
                                        showNoRecipientsFoundMessage = true
                                    }

                                    isSearchFocused = true
                                }
                            }

                            if isSearchExpanded {
                                Button(
                                    action: {
                                        isSearchFocused = false
                                        viewModel.searchText = ""

                                        Task {
                                            await viewModel.loadRecipients()
                                        }
                                    },
                                    label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: Dimensions.Icon.IconSizeXXXS,
                                                   height: Dimensions.Icon.IconSizeXXXS)
                                            .foregroundStyle(theme.onSurfaceVariant)
                                    })
                                .accessibilityLabel(languageSettings.localized("Clear text"))
                            }
                        }
                        .padding(.horizontal, Dimensions.Padding.SPadding)
                        .padding(.vertical, Dimensions.Padding.MSPadding)
                        .background(
                            RoundedRectangle(cornerRadius: Dimensions.Padding.MPadding, style: .continuous)
                                .fill(Color(.systemGray6))
                        )
                        .padding(.top, Dimensions.Padding.LPadding)
                        .padding(.bottom, Dimensions.Padding.SPadding)
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
                                emptyStateView(languageSettings.localized("Person or company does not own a valid certificate"))
                            } else {
                                filteredRecipientsSection
                            }

                            Spacer().frame(height: Dimensions.Padding.MSPadding)

                            if addedRecipients.count > 0 {
                                addedRecipientsSection
                            }
                        }
                    }
                    .padding(.horizontal, Dimensions.Padding.SPadding)

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
                .safeAreaInset(edge: .bottom) {
                    HStack(spacing: Dimensions.Padding.XSPadding) {
                        Button(action: {
                            if encryptionButtonEnabled {
                                encryptionButtonEnabled = false
                                pathManager.replaceLast(to: .encryptView(isWithEncryption: true))
                                encryptionButtonEnabled = true
                            }
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
                                    .accessibilityHidden(true)

                                Text(verbatim: encryptLabel)
                                    .foregroundStyle(theme.onPrimaryContainer)
                                    .font(typography.bodyLarge)
                                    .accessibilityHidden(true)
                            }
                        })
                    }
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
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(Dimensions.Padding.MPadding)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(encryptLabel.lowercased())
                    .accessibilityIdentifier("bottomEncryptButton")
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
                    guard !error.isEmpty else { return }
                    Toast.show(languageSettings.localized(error))
                    encryptionButtonEnabled = true
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
    EncryptRecipientView()
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
    .environment(NavigationPathManager())
}
