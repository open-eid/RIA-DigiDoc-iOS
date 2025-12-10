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

    @State private var isFileOpeningLoading = false
    @State private var isNavigatingToSigningView = false
    @State private var selectedRecipient: Addressee?
    @State private var showRemoveRecipientModal = false

    @State private var addedRecipients: [Addressee] = []

    @State private var viewModel: EncryptRecipientViewModel

    init() {
        _viewModel = State(wrappedValue: Container.shared.encryptRecipientViewModel())
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

    var body: some View {
        TopBarContainer(
            isTopBarHidden: isSearchExpanded,
            title: nil,
            onLeftClick: { dismiss() },
            showRightIcons: true,
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

                                viewModel.loadRecipients()
                                isSearchFocused = true
                            }

                            if isSearchExpanded {
                                Button(
                                    action: {
                                        isSearchFocused = false
                                        viewModel.searchText = ""
                                        viewModel.loadRecipients()
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

                        if noSearchResults && !isSearchExpanded {
                            List {
                                Text(languageSettings.localized("Crypto recipients description"))
                                    .font(typography.bodyLarge)
                                    .foregroundStyle(theme.onSurfaceVariant)
                                    .multilineTextAlignment(.leading)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                            }
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                        } else if noRecipients {
                            ContentUnavailableView {
                                Text(verbatim: languageSettings.localized("No recipients found"))
                                    .font(typography.bodyLarge)
                                    .foregroundStyle(theme.onSurfaceVariant)
                            }
                            .listRowSeparator(.hidden)
                        } else {
                            List {
                                if #available(iOS 26.0, *) {
                                    ForEach(filteredRecipients.enumerated(), id: \.offset
                                    ) { index, item in
                                        recipientRow(index: index, item: item)
                                    }
                                } else {
                                    ForEach(Array(filteredRecipients.enumerated()), id: \.offset
                                    ) { index, item in
                                        recipientRow(index: index, item: item)
                                    }
                                }
                            }
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                            .listRowSpacing(0)
                            .listSectionSpacing(.compact)
                        }
                        if addedRecipients.count > 0 {
                            if noSearchResults {
                                Text(verbatim: languageSettings.localized("Added recipients"))
                            } else {
                                Text(verbatim: languageSettings.localized("Recently added"))
                            }
                            List {
                                if #available(iOS 26.0, *) {
                                    ForEach(addedRecipients.enumerated(), id: \.offset
                                    ) { index, item in
                                        addedRecipientRow(index: index, item: item)
                                    }
                                } else {
                                    ForEach(Array(addedRecipients.enumerated()), id: \.offset
                                    ) { index, item in
                                        addedRecipientRow(index: index, item: item)
                                    }
                                }
                            }
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                            .listRowSpacing(0)
                            .listSectionSpacing(.compact)
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
                                    viewModel.loadRecipients()
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
                    viewModel.loadRecipients()
                    Task { @MainActor in
                        addedRecipients = await viewModel.filteredAddedRecipients()
                    }
                }
                .onChange(of: viewModel.errorMessage) { _, error in
                    guard !error.isEmpty else { return }
                    Toast.show(languageSettings.localized(error))
                }
//                .onChange(of: viewModel.searchText) { _, _ in
//                    Task { @MainActor in
//                        addedRecipients = await viewModel.filteredAddedRecipients()
//                    }
//                }
                .onChange(of: isNavigatingToSigningView, { _, newValue in
                    if newValue {
                        pathManager.navigate(to: .signingView)
                        isNavigatingToSigningView = false
                    }
                })
            }
        )
    }

    @ViewBuilder
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

    @ViewBuilder
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
}

#Preview {
    EncryptRecipientView()
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
    .environment(NavigationPathManager())
}
