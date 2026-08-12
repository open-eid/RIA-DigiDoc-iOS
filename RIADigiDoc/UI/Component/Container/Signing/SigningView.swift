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
import LibdigidocLibSwift
import CommonsLib
import UtilsLib

struct SigningView: View {
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @AppTheme private var theme
    @AppTypography private var typography
    @Environment(LanguageSettings.self) private var languageSettings

    @Environment(NavigationPathManager.self) private var pathManager

    private let nameUtil: NameUtilProtocol
    private let signatureUtil: SignatureUtilProtocol
    private let fileUtil: FileUtilProtocol

    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: SigningViewTab = .files

    @State private var selectedSignature: SignatureWrapper?

    @State private var viewModel: SigningViewModel

    @State private var tempContainerURL: URL?
    @State private var isFileSaved: Bool = false
    @State private var showRenameModal = false
    @State private var showRemoveSignatureModal = false
    @State private var showRemoveDataFileModal = false
    @State private var showExtendSignaturesModal = false
    @State private var isImportingAddedFiles: Bool = false

    @State private var showingShareSheet = false
    @State private var isSignButtonShown = false
    @State private var isEncryptButtonShown = false
    @State private var selectedDataFile: DataFileWrapper?

    @State private var showSivaMessage = false

    @State private var scrollPosition: Int?
    @State private var focusedSignatureIndex: Int?

    private var containerTitle: String {
        !isContainerSigned && !isNestedContainer ?
        languageSettings.localized("Container signing") :
        containerFilesTitle
    }

    private var containerNameTitle: String {
        languageSettings.localized("Container name")
    }

    private var containerSignaturesTitle: String {
        languageSettings.localized("Container signatures")
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

    private var isSignedContainer: Bool {
        viewModel.signatures.count > 0
    }

    private var closeIcon: String {
        !isNestedContainer ? "ic_m3_close_48pt_wght400" :
        "ic_m3_arrow_back_ios_48pt_wght400"
    }

    private var closeIconAccessibility: String {
        !isNestedContainer ? languageSettings.localized("Close container") :
        languageSettings.localized("Back")
    }

    private var containerIcon: String {
        viewModel.isSigned()
        ? "ic_m3_stylus_note_48pt_wght400"
        : "ic_m3_folder_48pt_wght400"
    }

    private var containerNotificationsIconAccessibility: String {
        let containerNotificationsCount = viewModel.containerNotifications.count
        let notificationKey = containerNotificationsCount == 1
        ? "Container notification"
        : "Container notifications"

        return "\(containerNotificationsCount) \(languageSettings.localized(notificationKey))"
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

    private var encryptAccessibilityLabel: String {
        languageSettings.localized("Encrypt container")
    }

    private var addMoreFilesLabel: String {
        languageSettings.localized("Add more files")
    }

    private var isContainerSigned: Bool {
        viewModel.isSigned()
    }

    private var isNestedContainer: Bool {
        viewModel.isNestedContainer()
    }

    private var isExtendSignaturesButtonShown: Bool {
        isSignedContainer && !isNestedContainer
    }

    private var extendSignaturesLabel: String {
        languageSettings.localized("Extend signatures")
    }

    private var containerName: String {
        URL(fileURLWithPath: viewModel.containerName)
            .deletingPathExtension()
            .lastPathComponent
    }

    private var containerExtension: String {
        URL(fileURLWithPath: viewModel.containerName).pathExtension
    }

    @State private var containerLoadingTask: Task<Void, Never>?

    init(
        nameUtil: NameUtilProtocol = Container.shared.nameUtil(),
        signatureUtil: SignatureUtilProtocol = Container.shared.signatureUtil(),
        fileUtil: FileUtilProtocol = Container.shared.fileUtil()
    ) {
        _viewModel = State(wrappedValue: Container.shared.signingViewModel())
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
                extraButtonIconAccessibility: containerNotificationsIconAccessibility,
                showExtraButton: !viewModel.containerNotifications.isEmpty,
                extraBadgeCount: viewModel.containerNotifications.count,
                onExtraButtonClick: {
                    pathManager.navigate(to:
                            .containerNotificationsView(notifications: viewModel.containerNotifications)
                    )
                },
                content: {
                    VStack(alignment: .leading, spacing: Dimensions.Padding.ZeroPadding) {
                        ScrollView {
                            VStack {
                                ContainerNameView(
                                    icon: containerIcon,
                                    containerNameTitle: containerNameTitle,
                                    name: $viewModel.containerName,
                                    isEditContainerButtonShown: !isContainerSigned && !isNestedContainer,
                                    isSaveButtonShown: true,
                                    isSignButtonShown: false,
                                    isEncryptButtonShown: !isContainerSigned && !isNestedContainer,
                                    isExtendSignaturesButtonShown: isExtendSignaturesButtonShown,
                                    showLeftActionButton: isContainerSigned && isSignButtonShown,
                                    showRightActionButton: isContainerSigned && !isNestedContainer,
                                    leftActionButtonName: languageSettings.localized("Add signature"),
                                    rightActionButtonName: encryptLabel,
                                    leftActionButtonAccessibilityLabel: signAccessibilityLabel.lowercased(),
                                    rightActionButtonAccessibilityLabel: encryptAccessibilityLabel.lowercased(),
                                    onLeftActionButtonClick: {
                                        pathManager.navigate(to: .signingRootView)
                                    },
                                    onRightActionButtonClick: {
                                        Task {
                                            await convertToCryptoContainer()
                                        }
                                    },
                                    onSaveContainerButtonClick: {
                                        tempContainerURL = viewModel.createCopyOfContainerForSaving(
                                            containerURL: viewModel.containerURL
                                        )

                                        if let containerURL = tempContainerURL {
                                            viewModel.removeLastOpenedXattr(from: containerURL)
                                        }

                                        if fileUtil.fileExists(fileLocation: tempContainerURL) {
                                            viewModel.isShowingContainerFileSaver = true
                                        }
                                    },
                                    onRenameContainerButtonClick: {
                                        showRenameModal = true
                                    },
                                    onSignContainerButtonClick: {
                                        // Do nothing
                                    },
                                    onEncryptContainerButtonClick: {
                                        Task {
                                            await convertToCryptoContainer()
                                        }
                                    },
                                    onExtendSignaturesClick: {
                                        showExtendSignaturesModal = true
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
                                        await updateSignAndEncryptButtonVisibility()
                                    }
                                }

                                if isSignedContainer {
                                    TabView(selectedTab: $selectedTab, titles: [
                                        containerFilesTitle,
                                        containerSignaturesTitle
                                    ]) {
                                        if selectedTab == .files {
                                            DataFilesSection(
                                                viewModel: viewModel,
                                                isContainerSigned: isContainerSigned,
                                                isNestedContainer: isNestedContainer,
                                                selectedDataFile: $selectedDataFile,
                                                showSivaMessage: $showSivaMessage,
                                                isFileSaved: $isFileSaved,
                                                showRemoveDataFileModal: $showRemoveDataFileModal,
                                                navigateToNestedCryptoContainerView:
                                                    $viewModel.navigateToNestedCryptoContainerView
                                            )
                                        } else {
                                            SignaturesListView(
                                                signatures: viewModel.isTimestampedContainer ?
                                                [] : viewModel.signatures,
                                                timestamps: viewModel.isTimestampedContainer ?
                                                viewModel.signatures : viewModel.timestamps,
                                                selectedSignature: $selectedSignature,
                                                containerMimetype: $viewModel.containerMimetype,
                                                dataFilesCount: viewModel.dataFiles.count,
                                                focusedIndex: $focusedSignatureIndex,
                                                showRemoveSignatureButton: viewModel.isSignatureRemoveButtonShown(),
                                                showRemoveSignatureModal: $showRemoveSignatureModal,
                                                nameUtil: nameUtil,
                                                signatureUtil: signatureUtil
                                            )
                                            .environment(languageSettings)
                                        }
                                    }
                                    .padding(.top, Dimensions.Padding.LPadding)
                                } else {
                                    VStack(alignment: .leading, spacing: Dimensions.Padding.XSPadding) {
                                        Text(verbatim: languageSettings.localized("Container files"))
                                            .foregroundStyle(theme.onSurfaceVariant)
                                            .font(typography.labelLarge)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .accessibilityAddTraits([.isHeader])

                                        DataFilesSection(
                                            viewModel: viewModel,
                                            isContainerSigned: isContainerSigned,
                                            isNestedContainer: isNestedContainer,
                                            selectedDataFile: $selectedDataFile,
                                            showSivaMessage: $showSivaMessage,
                                            isFileSaved: $isFileSaved,
                                            showRemoveDataFileModal: $showRemoveDataFileModal,
                                            navigateToNestedCryptoContainerView:
                                                $viewModel.navigateToNestedCryptoContainerView
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
                                        .filePreview(item: $viewModel.previewFile)
                                    }
                                    .padding(.vertical, Dimensions.Padding.MPadding)
                                }
                            }
                        }
                        .padding(Dimensions.Padding.SPadding)
                        .scrollPosition(id: $scrollPosition, anchor: .bottom)
                        .onChange(of: viewModel.signatures.count) { previousCount, newCount in
                            guard newCount > previousCount else { return }
                            scrollToBottom()
                        }

                        if isSignedContainer {
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
                                showLeftButton: true,
                                leftButtonIconName: "ic_m3_add_48pt_wght400",
                                leftButtonLabel: addMoreFilesLabel,
                                leftButtonAccessibilityLabel: addMoreFilesLabel.lowercased(),
                                leftButtonAction: {
                                    isImportingAddedFiles = true
                                },

                                rightButtonEnabled: true,
                                rightButtonIconName: "ic_m3_stylus_note_48pt_wght400",
                                rightButtonLabel: signLabel,
                                rightButtonAccessibilityLabel: signAccessibilityLabel.lowercased(),
                                rightButtonAction: {
                                    pathManager.navigate(to: .signingRootView)
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
                                        guard let containerFile = viewModel.containerURL else { return }

                                        for url in urls {
                                            guard url.startAccessingSecurityScopedResource() else { continue }
                                        }

                                        isImportingAddedFiles = false
                                        await viewModel.addDataFiles(urls, to: containerFile)

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
                        DispatchQueue.main.async {
                            if viewModel.isSignatureAdded() {
                                selectedTab = .signatures
                            }
                        }

                        containerLoadingTask = Task {
                            await viewModel.loadContainerData(
                                signedContainer: viewModel.signedContainer
                            )

                            await updateSignAndEncryptButtonVisibility()
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

            if showRemoveSignatureModal {
                ConfirmModalView(
                    title: languageSettings.localized("Remove signature"),
                    message: languageSettings.localized("Remove signature from container"),
                    onConfirm: {
                        Task {
                            await handleRemoveSignature()
                        }
                    }, onCancel: {
                        showRemoveSignatureModal = false
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

            if showExtendSignaturesModal {
                ConfirmModalView(
                    title: languageSettings.localized("Extend signatures"),
                    message: languageSettings.localized("Extend signatures confirm message"),
                    confirmButtonTitle: languageSettings.localized("Extend"),
                    onConfirm: {
                        showExtendSignaturesModal = false
                        Task {
                            await viewModel.extendSignatures()
                        }
                    },
                    onCancel: { showExtendSignaturesModal = false }
                )
            }
        }
        .animation(.easeInOut, value: showRenameModal)
        .animation(.easeInOut, value: showRemoveSignatureModal)
        .animation(.easeInOut, value: showExtendSignaturesModal)
        .sivaConfirmationAlert(
            isPresented: $viewModel.showExtendSivaConfirmation,
            onConfirm: { confirmed in
                Task { await viewModel.openExtendedContainer(isSivaConfirmed: confirmed) }
            },
            onReadMore: {
                Task { await viewModel.openExtendedContainer(isSivaConfirmed: false) }
            }
        )
        .alert(
            languageSettings.localized("Container validity cannot be extended"),
            isPresented: $viewModel.showCannotExtendContainerDialog
        ) {
            Button(languageSettings.localized("OK")) {}
        } message: {
            Text(verbatim: languageSettings.localized(
                "Failed to extend signatures and wrapped to timestamped container."
            ))
        }
        .onChange(of: viewModel.errorMessage) { _, error in
            guard let error else { return }
            let localizedMessage = languageSettings.localized(error.key, [error.args.joined(separator: ", ")])
            Toast.show(localizedMessage)

            if voiceOverEnabled {
                AccessibilityUtil.announceMessage(localizedMessage)
            }

            viewModel.resetErrorMessage()
        }
        .onChange(of: viewModel.successMessage) { _, message in
            guard let message else { return }
            let localizedMessage = languageSettings.localized(message.key, [message.args.joined(separator: ", ")])
            Toast.show(localizedMessage, type: .success)

            if voiceOverEnabled {
                AccessibilityUtil.announceMessage(localizedMessage)
            }

            if message.key == "Signatures extended" {
                selectedTab = .signatures
            }

            viewModel.resetSuccessMessage()
        }
        .onChange(of: viewModel.navigateToNestedCryptoContainerView) { _, isNavigating in
            if isNavigating {
                viewModel.navigateToNestedCryptoContainerView.toggle()
                Task { @MainActor in
                    let cdocOption = await Container.shared.dataStore().getEncryptionCdocOption(false)
                    pathManager.navigate(
                        to: .encryptView(
                            isWithEncryption: false,
                            cdocOption: cdocOption,
                            selectedTab: .files
                        )
                    )
                }
            }
        }
    }

    private func scrollToBottom() {
        DispatchQueue.main.async {
            guard let lastSignature = viewModel.signatures.indices.last else { return }

            scrollPosition = lastSignature

            DispatchQueue.main.async {
                focusedSignatureIndex = lastSignature
            }
        }
    }

    private func updateSignAndEncryptButtonVisibility() async {
        let shouldShowSignButton = await viewModel
            .isSignButtonShown(
                signedContainer: viewModel.signedContainer,
                isNestedContainer: isNestedContainer
            )

        let shouldShowEncryptButton = await viewModel
            .isEncryptButtonShown(
                signedContainer: viewModel.signedContainer,
                isNestedContainer: isNestedContainer
            )

        await MainActor.run {
            isSignButtonShown = shouldShowSignButton
            isEncryptButtonShown = shouldShowEncryptButton
        }
    }

    private func handleRemoveSignature() async {
        guard let signature = selectedSignature else {
            Toast.show(languageSettings.localized("Failed to remove signature from container"))
            return
        }

        await viewModel.removeSignature(signature)
        selectedSignature = nil
        showRemoveSignatureModal = false

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

    private func handleFileRename(to newContainerName: String) async {
        showRenameModal = false
        guard !newContainerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let sanitizedContainerName = newContainerName.sanitized()
        let containerNameWithExtension =
            containerExtension.isEmpty
            ? sanitizedContainerName
            : "\(sanitizedContainerName).\(containerExtension)"
        await viewModel.renameContainer(to: containerNameWithExtension)
    }

    private func convertToCryptoContainer() async {
        let isConverted = await viewModel.convertToCryptoContainer()
        if isConverted {
            Toast.show(
                languageSettings.localized("Converted to crypto container"),
                type: .success
            )
            let cdocOption = await Container.shared.dataStore().getEncryptionCdocOption(false)
            await MainActor.run {
                pathManager.replaceLast(
                    to: .encryptView(
                        isWithEncryption: false,
                        cdocOption: cdocOption,
                        selectedTab: .files
                    )
                )
            }
        }
    }
}

#Preview {
    SigningView()
        .environment(Container.shared.languageSettings())
        .environment(Container.shared.themeSettings())
        .environment(NavigationPathManager())
}
