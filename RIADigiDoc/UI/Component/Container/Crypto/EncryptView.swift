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
import QuickLook
import FactoryKit
import LibdigidocLibSwift
import CommonsLib
import UtilsLib

struct EncryptView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppTheme private var theme
    @AppTypography private var typography
    @EnvironmentObject private var languageSettings: LanguageSettings

    private let nameUtil: NameUtilProtocol
    private let signatureUtil: SignatureUtilProtocol
    private let fileUtil: FileUtilProtocol

    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: EncryptViewTab = .files

    @StateObject private var viewModel: EncryptViewModel

    @State private var containerTitle: String = ""
    @State private var encryptDecryptLabel: String = ""
    @State private var encryptDecryptAccessibilityLabel: String = ""

    @State private var tempContainerURL: URL?
    @State private var isFileSaved: Bool = false
    @State private var showRenameModal = false
    @State private var showRemoveDataFileModal = false
    @State private var newContainerName = Constants.Container.DefaultName

    @State private var showingShareSheet = false

    @State private var selectedDataFile: URL?

    @State private var showSivaMessage = false

    @State private var isNavigatingToContainerNotificationsView = false

    @AccessibilityFocusState private var focusedField: AccessibilityField?

    private func containerTitle() async -> String {
        return await viewModel.isInitialCryptoContainer(
            cryptoContainer: viewModel.cryptoContainer,
            isNestedContainer: isNestedContainer
        ) ? languageSettings.localized("Container encryption") : containerFilesTitle
    }

    private func encryptDecryptLabel() async -> String {
        if await viewModel.isDecryptButtonShown(
            cryptoContainer: viewModel.cryptoContainer,
            isNestedContainer: isNestedContainer
        ) {
            return languageSettings.localized("Decrypt")
        } else if await viewModel.isEncryptButtonShown(
            cryptoContainer: viewModel.cryptoContainer,
            isNestedContainer: isNestedContainer
        ) {
            return languageSettings.localized("Encrypt")
        } else {
           return ""
        }
    }

    private func encryptDecryptAccessibilityLabel() async -> String {
        if await viewModel.isDecryptButtonShown(
            cryptoContainer: viewModel.cryptoContainer,
            isNestedContainer: isNestedContainer
        ) {
            return languageSettings.localized("Decrypt container")
        } else if await viewModel.isEncryptButtonShown(
            cryptoContainer: viewModel.cryptoContainer,
            isNestedContainer: isNestedContainer
        ) {
            return languageSettings.localized("Encrypt container")
        } else {
           return ""
        }
    }

    private var containerNameTitle: String {
        languageSettings.localized("Container name")
    }

    private var containerRecipientsTitle: String {
        languageSettings.localized("Container recipients")
    }

    private var containerFilesTitle: String {
        languageSettings.localized("Container files")
    }

    private var shareTitle: String {
        languageSettings.localized("Share")
    }

    private var shareAccessibilityTitle: String {
        languageSettings.localized("Share container")
    }

    private var closeIcon: String {
        !isNestedContainer ? "ic_m3_close_48pt_wght400" :
        "ic_m3_arrow_back_ios_48pt_wght400"
    }

    private var closeIconAccessibility: String {
        !isNestedContainer ? languageSettings.localized("Close container") :
        languageSettings.localized("Back")
    }

    private var signLabel: String {
        languageSettings.localized("Sign")
    }

    private var signAccessibilityLabel: String {
        languageSettings.localized("Sign container")
    }

    private var encryptLabel: String {
        languageSettings.localized("Encrypt")
    }

    private var addMoreFilesLabel: String {
        languageSettings.localized("Add more files")
    }

    private var isNestedContainer: Bool {
        viewModel.isNestedContainer()
    }

    @State private var containerLoadingTask: Task<Void, Never>?

    init(
        nameUtil: NameUtilProtocol = Container.shared.nameUtil(),
        signatureUtil: SignatureUtilProtocol = Container.shared.signatureUtil(),
        fileUtil: FileUtilProtocol = Container.shared.fileUtil()
    ) {
        _viewModel = StateObject(wrappedValue: Container.shared.encryptViewModel())
        self.nameUtil = nameUtil
        self.signatureUtil = signatureUtil
        self.fileUtil = fileUtil
    }

    var body: some View {
        ZStack {
            TopBarContainer(
                title: containerTitle,
                leftIcon: closeIcon,
                leftIconAccessibility:
                    languageSettings.localized(closeIconAccessibility).lowercased(),
                onLeftClick: {
                    Task {
                        if await viewModel.handleBackButton() {
                            dismiss()
                        }
                    }
                },
                onExtraButtonClick: {

                },
                content: {
                    VStack(alignment: .leading, spacing: Dimensions.Padding.ZeroPadding) {
                        ScrollView {
                            VStack {
                                ContainerNameView(
                                    icon: "ic_m3_stylus_note_48pt_wght400",
                                    containerNameTitle: containerNameTitle,
                                    name: $viewModel.containerName,
                                    isEditContainerButtonShown: viewModel.isEditButtonShown,
                                    isEncryptButtonShown: viewModel.isEncryptButtonShown,
                                    showLeftActionButton: viewModel.isSignButtonShown,
                                    showRightActionButton: viewModel.isEncryptButtonShown ||
                                        viewModel.isDecryptButtonShown,
                                    leftActionButtonName: signLabel,
                                    rightActionButtonName: encryptDecryptLabel,
                                    leftActionButtonAccessibilityLabel: signAccessibilityLabel.lowercased(),
                                    rightActionButtonAccessibilityLabel: encryptDecryptAccessibilityLabel.lowercased(),
                                    onLeftActionButtonClick: {
                                        // TODO: Implement signing functionality
                                    },
                                    onRightActionButtonClick: {
                                        // TODO: Implement encrypt functionality
                                    },
                                    onSaveContainerButtonClick: {
                                        tempContainerURL = viewModel.createCopyOfContainerForSaving(
                                            containerURL: viewModel.containerURL
                                        )

                                        if fileUtil.fileExists(fileLocation: tempContainerURL) {
                                            viewModel.isShowingContainerFileSaver = true
                                        }
                                    },
                                    onRenameContainerButtonClick: {
                                        showRenameModal = true
                                    }
                                )
                                .background(
                                    FileSaverHandler(
                                        isPresented: $viewModel.isShowingContainerFileSaver,
                                        fileURL: tempContainerURL,
                                        languageSettings: languageSettings,
                                        onComplete: {
                                            viewModel.removeSavedFilesDirectory()
                                        },
                                        isFileSaved: $isFileSaved
                                    )
                                )
                                .onChange(of: viewModel.isNestedContainer()) { _ in
                                    Task {
                                        await updateAsyncLabels()
                                        await viewModel.updateAsyncProperties()
                                    }
                                }

                                if viewModel.isContainerWithoutRecipients && !isNestedContainer {
                                    VStack(alignment: .leading, spacing: Dimensions.Padding.XSPadding) {
                                        Text(verbatim: languageSettings.localized("Container files"))
                                            .foregroundStyle(theme.onSurfaceVariant)
                                            .font(typography.labelLarge)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .accessibilityAddTraits([.isHeader])

                                        CryptoDataFilesSection(
                                            viewModel: viewModel,
                                            isContainerUnlocked: true,
                                            isNestedContainer: isNestedContainer,
                                            selectedDataFile: $selectedDataFile,
                                            showSivaMessage: $showSivaMessage,
                                            isFileSaved: $isFileSaved,
                                            showRemoveDataFileModal: $showRemoveDataFileModal
                                        )
                                        .background(
                                            FileSaverHandler(
                                                isPresented: $viewModel.isShowingFileSaver,
                                                fileURL: viewModel.selectedDataFile,
                                                languageSettings: languageSettings,
                                                onComplete: {
                                                    viewModel.removeSavedFilesDirectory()
                                                },
                                                isFileSaved: $isFileSaved
                                            )
                                        )
                                        .quickLookPreview($viewModel.previewFile)
                                    }
                                    .padding(.vertical, Dimensions.Padding.MPadding)
                                } else {
                                    TabView(selectedTab: $selectedTab, titles: [
                                        containerFilesTitle,
                                        containerRecipientsTitle
                                    ]) {
                                        if selectedTab == .files {
                                            if viewModel.shouldShowDatafiles {
                                                CryptoDataFilesSection(
                                                    viewModel: viewModel,
                                                    isContainerUnlocked: viewModel.isContainerUnlocked,
                                                    isNestedContainer: isNestedContainer,
                                                    selectedDataFile: $selectedDataFile,
                                                    showSivaMessage: $showSivaMessage,
                                                    isFileSaved: $isFileSaved,
                                                    showRemoveDataFileModal: $showRemoveDataFileModal
                                                )
                                            } else {
                                                // TODO: CryptoDataFilesLockedSection
                                            }
                                        } else {
                                            // TODO: RecipientListView
                                            // .environmentObject(languageSettings)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(Dimensions.Padding.SPadding)
                        if viewModel.isShareButtonShown {
                            if let containerFile = viewModel.containerURL {
                                ShareButtonBottomBar(
                                    iconName: "ic_m3_ios_share_48pt_wght400",
                                    label: shareTitle,
                                    accessibilityLabel: shareAccessibilityTitle,
                                    containerUrl: containerFile
                                )
                            }
                        } else {
                            UnsignedBottomBarView(
                                leftButtonIconName: "ic_m3_add_48pt_wght400",
                                leftButtonLabel: addMoreFilesLabel,
                                leftButtonAccessibilityLabel: addMoreFilesLabel.lowercased(),
                                leftButtonAction: {
                                    // TODO: Implement add more files functionality
                                },

                                rightButtonIconName: "ic_m3_encrypted_48pt_wght400",
                                rightButtonLabel: encryptLabel,
                                rightButtonAccessibilityLabel: encryptLabel.lowercased(),
                                rightButtonAction: {
                                    // TODO: Implement encrypt functionality
                                }
                            )
                        }
                    }
                    .onAppear {
                        containerLoadingTask = Task {
                            await viewModel.loadContainerData(
                                cryptoContainer: viewModel.cryptoContainer
                            )

                            await updateAsyncLabels()
                            await viewModel.updateAsyncProperties()
                        }
                    }
                    .onDisappear {
                        containerLoadingTask?.cancel()
                    }
                }
            )

            if showRenameModal {
                CryptoRenameModalView(
                    encryptViewModel: viewModel,
                    showRenameModal: $showRenameModal,
                    newContainerName: $newContainerName
                )
            }

            if showRemoveDataFileModal {
                ConfirmModalView(
                    title: languageSettings.localized("Remove datafile"),
                    message: languageSettings.localized(
                        viewModel.dataFiles.count == 1 ?
                        "Remove last datafile from container message" :
                            "Remove datafile from container message"
                    ),
                    onConfirm: {
                        Task {
                            await handleRemoveDataFile()
                        }
                    },
                    onCancel: { showRemoveDataFileModal = false }
                )
            }
        }
        .animation(.easeInOut, value: showRenameModal)
        .onReceive(viewModel.$errorMessage) { error in
            guard let error else { return }
            let (key, args) = error
            Toast.show(String(
                format: languageSettings.localized(key),
                args.joined(separator: ", "))
            )
        }
    }

    func updateAsyncLabels() async {
        let containerTitle = await containerTitle()
        let encryptDecryptLabel = await self.encryptDecryptLabel()
        let encryptDecryptAccessibilityLabel = await self.encryptDecryptAccessibilityLabel()

        await MainActor.run {
            self.containerTitle = containerTitle
            self.encryptDecryptLabel = encryptDecryptLabel
            self.encryptDecryptAccessibilityLabel = encryptDecryptAccessibilityLabel
        }
    }

    private func handleRemoveDataFile() async {
        guard let dataFile = selectedDataFile else {
            Toast.show(languageSettings.localized("Failed to remove datafile from container", [""]))
            return
        }

        await viewModel.removeDataFile(dataFile)
        selectedDataFile = nil
        showRemoveDataFileModal = false

        if viewModel.dataFiles.count == 1, viewModel.isLastDataFileRemoved {
            if await viewModel.handleBackButton() {
                dismiss()
            }
        }
    }
}

#Preview {
    EncryptView()
        .environmentObject(Container.shared.languageSettings())
        .environmentObject(Container.shared.themeSettings())
}
