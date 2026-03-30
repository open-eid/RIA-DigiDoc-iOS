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
import QuickLook
import FactoryKit
import CryptoObjCWrapper
import CommonsLib
import UtilsLib

struct EncryptView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppTheme private var theme
    @AppTypography private var typography
    @Environment(NavigationPathManager.self) private var pathManager
    @Environment(LanguageSettings.self) private var languageSettings

    private let nameUtil: NameUtilProtocol
    private let recipientUtil: RecipientUtilProtocol
    private let fileUtil: FileUtilProtocol

    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: EncryptViewTab = .files
    @State private var selectedRecipient: Addressee?

    @State private var viewModel: EncryptViewModel

    @State private var containerTitle: String = ""
    @State private var encryptDecryptLabel: String = ""
    @State private var encryptDecryptAccessibilityLabel: String = ""

    @State private var tempContainerURL: URL?
    @State private var isFileSaved: Bool = false

    @State private var isWithEncryption: Bool = false
    @State private var isWithDecryption: Bool = false
    @State private var encryptionButtonEnabled = true

    @State private var showRenameModal = false
    @State private var showRemoveDataFileModal = false
    @State private var showRemoveRecipientModal = false
    @State private var isImportingAddedFiles: Bool = false

    @State private var showingShareSheet = false

    @State private var selectedDataFile: URL?

    @State private var showSivaMessage = false

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

    private var encryptLabel: String {
        languageSettings.localized("Encrypt")
    }

    private var nextLabel: String {
        languageSettings.localized("Next")
    }

    private var addMoreFilesLabel: String {
        languageSettings.localized("Add more files")
    }

    private var isNestedContainer: Bool {
        viewModel.isNestedContainer()
    }

    private var containerName: String {
        URL(fileURLWithPath: viewModel.containerName)
            .deletingPathExtension()
            .lastPathComponent
    }

    private var containerExtension: String {
        URL(fileURLWithPath: viewModel.containerName).pathExtension
    }
    
    private var containerIcon: String {
        viewModel.isContainerDecrypted
            ? "ic_m3_encrypted_off_48pt_wght400"
            : (viewModel.isContainerEncrypted
                ? "ic_m3_encrypted_48pt_wght400"
                : "ic_m3_folder_48pt_wght400")
    }

    @State private var containerLoadingTask: Task<Void, Never>?

    init(
        isWithEncryption: Bool = false,
        isWithDecryption: Bool = false,
        nameUtil: NameUtilProtocol = Container.shared.nameUtil(),
        recipientUtil: RecipientUtilProtocol = Container.shared.recipientUtil(),
        fileUtil: FileUtilProtocol = Container.shared.fileUtil()
    ) {
        _viewModel = State(wrappedValue: Container.shared.encryptViewModel())
        self.isWithEncryption = isWithEncryption
        self.isWithDecryption = isWithDecryption
        self.nameUtil = nameUtil
        self.recipientUtil = recipientUtil
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
                content: {
                    VStack(alignment: .leading, spacing: Dimensions.Padding.ZeroPadding) {
                        ScrollView {
                            VStack {
                                ContainerNameView(
                                    icon: containerIcon,
                                    containerNameTitle: containerNameTitle,
                                    name: $viewModel.containerName,
                                    isEditContainerButtonShown: viewModel.isEditButtonShown,
                                    isSaveButtonShown: viewModel.isContainerEncrypted || viewModel.isContainerDecrypted,
                                    isSignButtonShown: viewModel.isSignButtonShown,
                                    isEncryptButtonShown: false,
                                    showLeftActionButton: false,
                                    showRightActionButton: viewModel.isEncryptButtonShown ||
                                        viewModel.isDecryptButtonShown,
                                    leftActionButtonName: "",
                                    rightActionButtonName: encryptDecryptLabel,
                                    leftActionButtonAccessibilityLabel: "",
                                    rightActionButtonAccessibilityLabel: encryptDecryptAccessibilityLabel.lowercased(),
                                    onLeftActionButtonClick: {
                                        // Do nothing
                                    },
                                    onRightActionButtonClick: {
                                        if viewModel.isEncryptButtonShown {
                                            if encryptionButtonEnabled {
                                                encryptionButtonEnabled = false
                                                Task {
                                                    await viewModel.encryptContainer()
                                                    await updateAsyncLabels()
                                                    await viewModel.updateAsyncProperties()

                                                    Toast.show(languageSettings.localized(
                                                        "Container successfully encrypted"
                                                    ), type: .success)

                                                    encryptionButtonEnabled = true
                                                }
                                            }
                                        } else if viewModel.isDecryptButtonShown {
                                            isWithEncryption = false
                                            isWithDecryption = false
                                            pathManager.navigate(to: .decryptRootView)
                                        }
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
                                    },
                                    onSignContainerButtonClick: {
                                        Task {
                                            await convertToSignedContainer()
                                        }
                                    },
                                    onEncryptContainerButtonClick: {
                                        // Do nothing
                                    }
                                )
                                .background(
                                    FileSaverHandler(
                                        isPresented: $viewModel.isShowingContainerFileSaver,
                                        fileURL: tempContainerURL,
                                        languageSettings: languageSettings,
                                        onComplete: {
                                            if !isNestedContainer {
                                                viewModel.removeSavedFilesDirectory()
                                            }
                                        },
                                        isFileSaved: $isFileSaved
                                    )
                                )
                                .onChange(of: viewModel.isNestedContainer()) {
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
                                            showOpenFileButton: true,
                                            showSaveFileButton: true,
                                            showRemoveFileButton: true,
                                            isNestedContainer: isNestedContainer,
                                            selectedDataFile: $selectedDataFile,
                                            showSivaMessage: $showSivaMessage,
                                            isFileSaved: $isFileSaved,
                                            showRemoveDataFileModal: $showRemoveDataFileModal,
                                            navigateToNestedSignedContainerView:
                                                $viewModel.navigateToNestedSignedContainerView
                                        )
                                        .background(
                                            FileSaverHandler(
                                                isPresented: $viewModel.isShowingFileSaver,
                                                fileURL: viewModel.selectedDataFile,
                                                languageSettings: languageSettings,
                                                onComplete: {
                                                    if !isNestedContainer {
                                                        viewModel.removeSavedFilesDirectory()
                                                    }
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
                                                    showOpenFileButton: viewModel.isContainerUnlocked,
                                                    showSaveFileButton: viewModel.isContainerUnlocked,
                                                    showRemoveFileButton: !viewModel.isContainerEncrypted &&
                                                        !viewModel.isContainerDecrypted,
                                                    isNestedContainer: isNestedContainer,
                                                    selectedDataFile: $selectedDataFile,
                                                    showSivaMessage: $showSivaMessage,
                                                    isFileSaved: $isFileSaved,
                                                    showRemoveDataFileModal: $showRemoveDataFileModal,
                                                    navigateToNestedSignedContainerView:
                                                        $viewModel.navigateToNestedSignedContainerView
                                                )
                                            } else {
                                                CryptoDataFilesLockedSection()
                                                    .environment(languageSettings)
                                            }
                                        } else {
                                            RecipientsListView(
                                                recipients: viewModel.recipients,
                                                selectedRecipient: $selectedRecipient,
                                                showRemoveRecipientButton: viewModel.isRecipientRemoveButtonShown(),
                                                showRemoveRecipientModal: $showRemoveRecipientModal,
                                                nameUtil: nameUtil,
                                                recipientUtil: recipientUtil
                                            )
                                            .environment(languageSettings)
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
                        } else if viewModel.isContainerUnencrypted {
                            let rightButtonLabel = viewModel.isContainerUnencrypted ? nextLabel : encryptLabel
                            let rightButtonIconName = viewModel.isContainerUnencrypted
                            ? "ic_m3_arrow_forward_48pt_wght400"
                            : "ic_m3_encrypted_48pt_wght400"
                            UnsignedBottomBarView(
                                showLeftButton: viewModel.isContainerUnencrypted,
                                leftButtonIconName: "ic_m3_add_48pt_wght400",
                                leftButtonLabel: addMoreFilesLabel,
                                leftButtonAccessibilityLabel: addMoreFilesLabel.lowercased(),
                                leftButtonAction: {
                                    isImportingAddedFiles = true
                                },
                                rightButtonEnabled: viewModel.isContainerUnencrypted || encryptionButtonEnabled,
                                rightButtonIconName: rightButtonIconName,
                                rightButtonLabel: rightButtonLabel,
                                rightButtonAccessibilityLabel: rightButtonLabel.lowercased(),
                                rightButtonAction: {
                                    if viewModel.isContainerUnencrypted {
                                        pathManager.replaceLast(to: .encryptRecipientView)
                                    } else {
                                        if encryptionButtonEnabled {
                                            encryptionButtonEnabled = false
                                            Task {
                                                await viewModel.encryptContainer()
                                                await updateAsyncLabels()
                                                await viewModel.updateAsyncProperties()

                                                encryptionButtonEnabled = true
                                                isWithEncryption = false
                                            }
                                        }
                                    }
                                }
                            )
                            .fileImporter(
                                isPresented: $isImportingAddedFiles,
                                allowedContentTypes: [.item],
                                allowsMultipleSelection: true
                            ) { result in
                                switch result {
                                case .success(let urls):
                                    Task {
                                        for url in urls {
                                            guard url.startAccessingSecurityScopedResource() else { continue }
                                        }

                                        isImportingAddedFiles = false
                                        await viewModel.addDataFiles(urls)

                                        for url in urls {
                                            url.stopAccessingSecurityScopedResource()
                                        }
                                    }

                                case .failure:
                                    isImportingAddedFiles = false
                                }
                            }
                        }
                    }
                    .onAppear {
                        containerLoadingTask = Task {
                            if isWithEncryption {
                                await viewModel.encryptContainer()
                                await updateAsyncLabels()
                                await viewModel.updateAsyncProperties()

                                encryptionButtonEnabled = true
                                isWithEncryption = false
                            } else if isWithDecryption {
                                await updateAsyncLabels()
                                await viewModel.updateAsyncProperties()

                                Toast.show(languageSettings.localized(
                                    "Container successfully decrypted"
                                ), type: .success)
                                isWithDecryption = false
                            } else {
                                await viewModel.loadContainerData(
                                    cryptoContainer: nil
                                )

                                await updateAsyncLabels()
                                await viewModel.updateAsyncProperties()
                            }
                        }
                    }
                    .onDisappear {
                        containerLoadingTask?.cancel()
                    }
                }
            )

            if showRenameModal {
                RenameModalView(
                    containerName: containerName,
                    onConfirm: { newContainerName in
                        Task {
                            await handleFileRename(to: newContainerName)
                        }
                    },
                    onCancel: {
                        showRenameModal = false
                    }
                )
            }

            if showRemoveRecipientModal {
                ConfirmModalView(
                    title: languageSettings.localized("Remove recipient"),
                    message: languageSettings.localized("Remove recipient from container"),
                    onConfirm: {
                        Task {
                            await handleRemoveRecipient()
                        }
                    }, onCancel: {
                        showRemoveRecipientModal = false
                    }
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
        .onChange(of: viewModel.errorMessage) { _, error in
            guard let error else { return }
            Toast.show(
                languageSettings.localized(error.key, [error.args.joined(separator: ", ")])
            )
            viewModel.resetErrorMessage()
            encryptionButtonEnabled = true
        }
        .onChange(of: viewModel.successMessage) { _, message in
            guard let message else { return }
            Toast.show(
                languageSettings.localized(message.key, [message.args.joined(separator: ", ")]),
                type: .success
            )
            viewModel.resetSuccessMessage()
        }
        .onChange(of: viewModel.navigateToNestedSignedContainerView) { _, isNavigating in
            if isNavigating {
                viewModel.navigateToNestedSignedContainerView.toggle()
                pathManager.navigate(to: .signingView)
            }
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

    private func handleRemoveRecipient() async {
        guard let recipient = selectedRecipient else {
            Toast.show(languageSettings.localized("Failed to remove recipient from container"))
            return
        }

        await viewModel.removeRecipient(recipient)
        selectedRecipient = nil
        showRemoveRecipientModal = false
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

    private func convertToSignedContainer() async {
        let isConverted = await viewModel.convertToSignedContainer()
        if isConverted {
            Toast.show(
                languageSettings.localized("Converted to a signature container"),
                type: .success
            )
            await MainActor.run {
                pathManager.replaceLast(to: .signingView)
            }
        }
    }

    private func handleFileRename(to newContainerName: String) async {
        showRenameModal = false
        let sanitizedContainerName = newContainerName.sanitized()
        guard !sanitizedContainerName.isEmpty else { return }
        let containerNameWithExtension =
            containerExtension.isEmpty
            ? sanitizedContainerName
            : "\(sanitizedContainerName).\(containerExtension)"
        await viewModel.renameContainer(to: containerNameWithExtension)
    }
}

#Preview {
    EncryptView()
        .environment(Container.shared.languageSettings())
        .environment(Container.shared.themeSettings())
        .environment(NavigationPathManager())
}
