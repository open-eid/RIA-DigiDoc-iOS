import SwiftUI
import QuickLook
import FactoryKit
import LibdigidocLibSwift
import CommonsLib
import UtilsLib

struct SigningView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppTheme private var theme
    @AppTypography private var typography
    @EnvironmentObject private var languageSettings: LanguageSettings

    private let nameUtil: NameUtilProtocol
    private let signatureUtil: SignatureUtilProtocol
    private let fileUtil: FileUtilProtocol

    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0

    @State private var selectedSignature: SignatureWrapper?

    @StateObject private var viewModel: SigningViewModel

    @State private var tempContainerURL: URL?
    @State private var isFileSaved: Bool = false
    @State private var showRenameDialog = false
    @State private var newContainerName = Constants.Container.DefaultName

    @State private var showingShareSheet = false

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

    private var isSignedContainer: Bool {
        viewModel.signatures.count > 0
    }

    private var closeIcon: String {
        !isNestedContainer ? "ic_m3_close_48pt_wght400" :
        "ic_m3_arrow_back_ios_48pt_wght400"
    }

    private var signLabel: String {
        languageSettings.localized("Sign")
    }

    private var encryptLabel: String {
        languageSettings.localized("Encrypt")
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

    init(
        viewModel: SigningViewModel = Container.shared.signingViewModel(),
        nameUtil: NameUtilProtocol = Container.shared.nameUtil(),
        signatureUtil: SignatureUtilProtocol = Container.shared.signatureUtil(),
        fileUtil: FileUtilProtocol = Container.shared.fileUtil()
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
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
                    languageSettings.localized(closeIcon).lowercased(),
                onLeftClick: {
                    Task {
                        if await viewModel.handleBackButton() {
                            dismiss()
                        }
                    }
                },
                content: {
                    VStack(alignment: .leading, spacing: Dimensions.Padding.ZeroPadding) {
                        VStack {
                            ContainerNameView(
                                icon: "ic_m3_stylus_note_48pt_wght400",
                                containerNameTitle: containerNameTitle,
                                name: $viewModel.containerName,
                                isEditContainerButtonShown: !isContainerSigned && !isNestedContainer,
                                isEncryptButtonShown: !isContainerSigned && !isNestedContainer,
                                showLeftActionButton: isContainerSigned && !isNestedContainer,
                                showRightActionButton: isContainerSigned && !isNestedContainer,
                                leftActionButtonName: signLabel,
                                rightActionButtonName: encryptLabel,
                                leftActionButtonAccessibilityLabel: signLabel.lowercased(),
                                rightActionButtonAccessibilityLabel: encryptLabel.lowercased(),
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
                                        viewModel.isShowingFileSaver = true
                                    }
                                },
                                onRenameContainerButtonClick: {
                                    showRenameDialog = true
                                }
                            )
                            .background(
                                FileSaverHandler(
                                    isPresented: $viewModel.isShowingFileSaver,
                                    fileURL: tempContainerURL,
                                    languageSettings: languageSettings,
                                    onComplete: {
                                        viewModel.removeSavedFilesDirectory()
                                    },
                                    isFileSaved: $isFileSaved
                                )
                            )

                            if isSignedContainer {
                                TabView(selectedTab: $selectedTab, titles: [
                                    containerFilesTitle,
                                    containerSignaturesTitle
                                ]) {
                                    if selectedTab == 0 {
                                        DataFilesListView(
                                            dataFiles: viewModel.dataFiles,
                                            showRemoveFileButton: !isContainerSigned && !isNestedContainer,
                                            onOpenFileButtonClick: { dataFile in
                                                Task {
                                                    await viewModel.handleFileOpening(dataFile: dataFile)
                                                }
                                            },
                                            onSaveDataFileButtonClick: { dataFile in
                                                Task {
                                                    await viewModel.handleSaveFile(dataFile: dataFile)
                                                }
                                            }
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
                                    } else {
                                        SignaturesListView(
                                            signatures: viewModel.signatures,
                                            selectedSignature: $selectedSignature,
                                            containerMimetype: $viewModel.containerMimetype,
                                            dataFilesCount: viewModel.dataFiles.count,
                                            showRemoveSignatureButton: !isNestedContainer,
                                            nameUtil: nameUtil,
                                            signatureUtil: signatureUtil
                                        )
                                        .environmentObject(languageSettings)
                                    }
                                }
                            } else {
                                VStack(alignment: .leading, spacing: Dimensions.Padding.XSPadding) {
                                    Text(verbatim: languageSettings.localized("Container files"))
                                        .foregroundStyle(theme.onSurfaceVariant)
                                        .font(typography.labelLarge)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    DataFilesListView(
                                        dataFiles: viewModel.dataFiles,
                                        showRemoveFileButton: !isContainerSigned && !isNestedContainer,
                                        onOpenFileButtonClick: { dataFile in
                                            Task {
                                                await viewModel.handleFileOpening(dataFile: dataFile)
                                            }
                                        },
                                        onSaveDataFileButtonClick: { dataFile in
                                            Task {
                                                await viewModel.handleSaveFile(dataFile: dataFile)
                                            }
                                        }
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
                            }
                        }
                        .padding(Dimensions.Padding.SPadding)

                        if isSignedContainer {
                            if let containerFile = viewModel.containerURL {
                                ShareButtonBottomBar(
                                    iconName: "ic_m3_ios_share_48pt_wght400",
                                    label: shareTitle,
                                    accessibilityLabel: shareTitle,
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

                                rightButtonIconName: "ic_m3_stylus_note_48pt_wght400",
                                rightButtonLabel: signLabel,
                                rightButtonAccessibilityLabel: signLabel.lowercased(),
                                rightButtonAction: {
                                    // TODO: Implement signing functionality
                                }
                            )
                        }
                    }
                    .onAppear {
                        Task {
                            await viewModel.loadContainerData(
                                signedContainer: viewModel.signedContainer
                            )
                        }
                    }
                }
            )

            if showRenameDialog {
                // Make the background darker to focus on the dialog
                Color.black
                    .opacity(Dimensions.Shadow.LOpacity)
                    .ignoresSafeArea()

                Dialog(
                    icon: "ic_m3_edit_48pt_wght400",
                    title: languageSettings.localized("Change container name"),
                    placeholder: viewModel.containerName,
                    text: Binding<String>(
                        get: {
                            URL(fileURLWithPath: viewModel.containerName).deletingPathExtension().lastPathComponent
                        },
                        set: { newValue in
                            let existingExtension = URL(fileURLWithPath: viewModel.containerName).pathExtension

                            let newValueURL = URL(fileURLWithPath: newValue)

                            let containerExtension =
                            existingExtension.isEmpty ? Constants.Extension.Default : existingExtension

                            newContainerName = newValueURL
                                .appendingPathExtension(containerExtension)
                                .lastPathComponent
                        }),
                    onConfirm: {
                        showRenameDialog = false
                        Task {
                            let uniqueContainerName = await viewModel.renameContainer(to: newContainerName)
                            defer { newContainerName = "" }

                            if uniqueContainerName != nil {
                                viewModel.containerName =
                                uniqueContainerName?.lastPathComponent ?? viewModel.containerName
                            }
                        }
                    },
                    onCancel: {
                        showRenameDialog = false
                        newContainerName = ""
                    }
                )
            }
        }
        .animation(.easeInOut, value: showRenameDialog)
        .onReceive(viewModel.$errorMessage) { error in
            guard let error else { return }
            let (key, args) = error
            Toast.show(String(
                format: languageSettings.localized(key),
                args.joined(separator: ", "))
            )
        }
    }
}

#Preview {
    SigningView()
        .environmentObject(
            Container.shared.languageSettings()
        )
}
