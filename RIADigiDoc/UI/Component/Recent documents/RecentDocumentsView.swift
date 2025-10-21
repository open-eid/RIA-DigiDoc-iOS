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

struct RecentDocumentsView: View {
    @EnvironmentObject private var languageSettings: LanguageSettings

    @State private var isFileOpeningLoading = false
    @State private var isNavigatingToSigningView = false
    @State private var isRefreshing = false

    @StateObject private var viewModel: RecentDocumentsViewModel

    init() {
        _viewModel = StateObject(wrappedValue: Container.shared.recentDocumentsViewModel())
    }

    var body: some View {
        VStack {
            HStack {
                TextField(languageSettings.localized("Search container file"), text: $viewModel.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocorrectionDisabled(true)
                    .padding(.leading, 8)
                    .disabled(viewModel.files.count < 2)
                    .opacity(viewModel.files.count < 2 ? 0 : 1.0)
                    .onChange(of: viewModel.searchText) { _ in
                        viewModel.loadFiles()
                    }

                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.searchText = ""
                    }, label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray)
                            .accessibilityLabel(languageSettings.localized("Remove"))
                    })
                    .padding(.trailing, 8)
                }
            }
            .padding()

            List {
                if viewModel.filteredFiles.isEmpty {
                    Text(
                        viewModel.searchText.isEmpty ? languageSettings.localized("No recent documents") :
                            languageSettings.localized("Document not found")
                    )
                    .font(.headline)
                    .foregroundStyle(.gray)
                    .padding()
                    Spacer()
                } else {
                    ForEach(viewModel.filteredFiles) { file in
                        Button(action: {
                            self.viewModel.setChosenFiles(.success([file.url]))
                            self.isFileOpeningLoading = true
                        }, label: {
                            RecentDocumentFileRow(file: file)
                        })
                        .buttonStyle(.plain)
                    }
                    .onDelete(perform: viewModel.deleteFile)
                }
            }
            .refreshable {
                viewModel.loadFiles()
            }
            .fullScreenCover(isPresented: $isFileOpeningLoading) {
                FileOpeningView(
                    isFileOpeningLoading: $isFileOpeningLoading,
                    isNavigatingToNextView: $isNavigatingToSigningView
                )
            }

            NavigationLink(
                destination: SigningView(),
                isActive: $isNavigatingToSigningView
            ) {}
        }
        .navigationTitle(languageSettings.localized("Recent documents"))
        .onAppear {
            viewModel.loadFiles()
        }
    }
}

#Preview {
    RecentDocumentsView()
        .environmentObject(Container.shared.languageSettings())
        .environmentObject(Container.shared.themeSettings())
}
