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

struct RecentDocumentsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var languageSettings: LanguageSettings

    @AppTheme private var theme
    @AppTypography private var typography

    @State private var isFileOpeningLoading = false
    @State private var isNavigatingToSigningView = false
    @State private var selectedFile: FileItem?
    @State private var showRemoveContainerModal = false

    @StateObject private var viewModel: RecentDocumentsViewModel

    let folderURL: URL?
    let extensions: [String]

    init(folderURL: URL?, extensions: [String]) {
        _viewModel = StateObject(wrappedValue: Container.shared.recentDocumentsViewModel())
        self.folderURL = folderURL
        self.extensions = extensions
    }

    var filteredFiles: [FileItem] {
        viewModel.filteredFiles(using: extensions)
    }

    var noDocuments: Bool {
        filteredFiles.isEmpty
    }

    var noSearchResults: Bool {
        !viewModel.searchText.isEmpty && noDocuments
    }

    var body: some View {
        TopBarContainer(
            title: nil,
            onLeftClick: { dismiss() },
            showRightIcons: true,
            content: {
                ZStack {
                    if #available(iOS 17.0, *) {
                        VStack(alignment: .leading, spacing: Dimensions.Padding.ZeroPadding) {
                            Text(verbatim: languageSettings.localized("Recent documents"))
                                .foregroundStyle(theme.onSurface)
                                .font(typography.headlineSmall)
                                .padding(.top, Dimensions.Padding.SPadding)
                                .accessibilityHeading(.h1)
                                .accessibilityAddTraits([.isHeader])

                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundStyle(theme.onSurfaceVariant)
                                    .accessibilityHidden(true)

                                TextField(
                                    languageSettings.localized("Search container file"),
                                    text: $viewModel.searchText
                                )
                                .submitLabel(.done)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .onChange(of: viewModel.searchText) { _ in
                                    guard let recentDocumentsFolder = folderURL else { return }
                                    viewModel.loadFiles(
                                        from: recentDocumentsFolder,
                                        withExtensions: extensions
                                    )
                                }

                                if !viewModel.searchText.isEmpty {
                                    Button(
                                        action: {
                                            viewModel.searchText = ""
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

                            NavigationStack {
                                if noSearchResults {
                                    ContentUnavailableView {
                                        Text(verbatim: languageSettings.localized("Document not found"))
                                    }
                                    .listRowSeparator(.hidden)
                                } else if noDocuments {
                                    ContentUnavailableView {
                                        Text(verbatim: languageSettings.localized("No recent documents"))
                                    }
                                    .listRowSeparator(.hidden)
                                } else {
                                    List {
                                        if #available(iOS 26.0, *) {
                                            ForEach(filteredFiles.enumerated(), id: \.offset
                                            ) { index, item in
                                                fileRow(index: index, item: item)
                                            }
                                        } else {
                                            ForEach(Array(filteredFiles.enumerated()), id: \.offset
                                            ) { index, item in
                                                fileRow(index: index, item: item)
                                            }
                                        }
                                    }
                                    .listStyle(.plain)
                                    .scrollContentBackground(.hidden)
                                    .listRowSpacing(0)
                                    .listSectionSpacing(.compact)
                                    .fullScreenCover(isPresented: $isFileOpeningLoading) {
                                        FileOpeningView(
                                            isFileOpeningLoading: $isFileOpeningLoading,
                                            isNavigatingToNextView: $isNavigatingToSigningView
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, Dimensions.Padding.SPadding)
                    } else {
                        EmptyView()
                    }

                    NavigationLink(
                        destination: SigningView(),
                        isActive: $isNavigatingToSigningView
                    ) {}
                        .accessibilityHidden(!isNavigatingToSigningView)

                    if showRemoveContainerModal {
                        ConfirmModalView(
                            title: "\(languageSettings.localized("Remove container"))?",
                            message: languageSettings.localized("Remove container message"),
                            onConfirm: {
                                guard let file = selectedFile else {
                                    Toast.show(languageSettings.localized("Failed to remove file"))
                                    return
                                }

                                viewModel.deleteFile(file)
                                selectedFile = nil
                                showRemoveContainerModal = false
                                guard let recentDocumentsFolder = folderURL else { return }
                                viewModel.loadFiles(
                                    from: recentDocumentsFolder,
                                    withExtensions: extensions
                                )
                            },
                            onCancel: {
                                selectedFile = nil
                                showRemoveContainerModal = false
                            }
                        )
                    }
                }
                .onAppear {
                    guard let recentDocumentsFolder = folderURL else { return }
                    viewModel.loadFiles(
                        from: recentDocumentsFolder,
                        withExtensions: extensions
                    )
                }
                .onReceive(viewModel.$errorMessage) { error in
                    guard !error.isEmpty else { return }
                    Toast.show(languageSettings.localized(error))
                }
            }
        )
    }

    @ViewBuilder
    private func fileRow(index: Int, item: FileItem) -> some View {
        RecentDocumentFileView(
            file: item,
            fileIndex: index,
            onOpenContainer: {
                viewModel.setChosenFiles(.success([item.url]))
                isFileOpeningLoading = true
            },
            onRemoveContainer: {
                selectedFile = item
                showRemoveContainerModal = true
            }
        )
        .padding(.vertical, Dimensions.Padding.SPadding)
        .listRowInsets(EdgeInsets())
        .contentShape(Rectangle())
        .buttonStyle(.plain)
    }
}

#Preview {
    RecentDocumentsView(
        folderURL: URL(fileURLWithPath: "/recentDocumentsFolder/"),
        extensions: Constants.Container.ContainerExtensions
    )
    .environmentObject(Container.shared.languageSettings())
    .environmentObject(Container.shared.themeSettings())
}
