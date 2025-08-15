import SwiftUI
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
    @State private var selectedDataFile: URL?

    @State private var selectedSignature: SignatureWrapper?

    @StateObject private var viewModel: SigningViewModel
    private var sharedContainerViewModel: SharedContainerViewModelProtocol

    @State private var tempContainerURL: URL?
    @State private var isShowingFileSaver = false
    @State private var isFileSaved: Bool = false
    @State private var showRenameDialog = false
    @State private var newContainerName = Constants.Container.DefaultName

    @State private var showingShareSheet = false

    private var containerFilesTitle: String {
        languageSettings.localized("Container files")
    }

    private var containerNameTitle: String {
        languageSettings.localized("Container name")
    }

    private var containerSignaturesTitle: String {
        languageSettings.localized("Container signatures")
    }

    private var shareTitle: String {
        languageSettings.localized("Share")
    }

    private var isSignedContainer: Bool {
        viewModel.signatures.count > 0
    }

    init(
        viewModel: SigningViewModel = Container.shared.signingViewModel(),
        nameUtil: NameUtilProtocol = Container.shared.nameUtil(),
        signatureUtil: SignatureUtilProtocol = Container.shared.signatureUtil(),
        fileUtil: FileUtilProtocol = Container.shared.fileUtil(),
        sharedContainerViewModel: SharedContainerViewModelProtocol = Container.shared.sharedContainerViewModel()
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.nameUtil = nameUtil
        self.signatureUtil = signatureUtil
        self.fileUtil = fileUtil
        self.sharedContainerViewModel = sharedContainerViewModel
    }

    var body: some View {
        ZStack {
            TopBarContainer(
                title: containerFilesTitle,
                onLeftClick: { dismiss()
 },
                content: {
                    VStack(alignment: .leading, spacing: Dimensions.Padding.ZeroPadding) {
                        VStack {
                            ContainerNameView(
                                icon: "ic_m3_stylus_note_48pt_wght400",
                                containerNameTitle: containerNameTitle,
                                name: $viewModel.containerName,
                                isEditContainerButtonShown: !viewModel.isSigned(),
                                isEncryptButtonShown: !viewModel.isSigned(),
                                showLeftActionButton: viewModel.isSigned(),
                                showRightActionButton: viewModel.isSigned(),
                                leftActionButtonName: languageSettings.localized("Sign"),
                                rightActionButtonName: languageSettings.localized("Encrypt"),
                                leftActionButtonAccessibilityLabel: languageSettings.localized("Sign"),
                                rightActionButtonAccessibilityLabel: languageSettings.localized("Encrypt"),
                                onLeftActionButtonClick: {},
                                onRightActionButtonClick: {},
                                onSaveContainerButtonClick: {
                                    tempContainerURL = viewModel.createCopyOfContainerForSaving(
                                        containerURL: viewModel.containerURL
                                    )

                                    if fileUtil.fileExists(fileLocation: tempContainerURL) {
                                        isShowingFileSaver = true
                                    }
                                },
                                onRenameContainerButtonClick: {
                                    showRenameDialog = true
                                }
                            )
                            .background(
                                FileSaverHandler(
                                    isPresented: $isShowingFileSaver,
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
                                            showRemoveFileButton: !viewModel.isSigned(),
                                            onSaveDataFileButtonClick: { dataFile in
                                                Task {
                                                    let result = await viewModel.getDataFileURL(dataFile)

                                                    await MainActor.run {
                                                        switch result {
                                                        case .success(let fileURL):
                                                            selectedDataFile = fileURL
                                                            isShowingFileSaver = true

                                                        case .failure:
                                                            let message = String(
                                                                format: languageSettings
                                                                    .localized("Failed to save file %@"),
                                                                dataFile.fileName
                                                            )
                                                            isShowingFileSaver = false
                                                            Toast.show(message)
                                                        }
                                                    }
                                                }
                                            }
                                        )
                                        .background(
                                            FileSaverHandler(
                                                isPresented: $isShowingFileSaver,
                                                fileURL: selectedDataFile,
                                                languageSettings: languageSettings,
                                                onComplete: {
                                                    viewModel.removeSavedFilesDirectory()
                                                },
                                                isFileSaved: $isFileSaved
                                            )
                                        )
                                    } else {
                                        SignaturesListView(
                                            signatures: viewModel.signatures,
                                            selectedSignature: $selectedSignature,
                                            containerMimetype: $viewModel.containerMimetype,
                                            dataFilesCount: viewModel.dataFiles.count,
                                            nameUtil: nameUtil,
                                            signatureUtil: signatureUtil
                                        )
                                        .environmentObject(languageSettings)
                                    }
                                }
                            } else {
                                VStack(alignment: .leading, spacing: Dimensions.Padding.XSPadding) {
                                    Text(containerFilesTitle)
                                        .foregroundStyle(theme.onSurfaceVariant)
                                        .font(typography.labelLarge)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    DataFilesListView(
                                        dataFiles: viewModel.dataFiles,
                                        showRemoveFileButton: !viewModel.isSigned(),
                                        onSaveDataFileButtonClick: { dataFile in
                                            Task {
                                                let result = await viewModel.getDataFileURL(dataFile)

                                                await MainActor.run {
                                                    switch result {
                                                    case .success(let fileURL):
                                                        selectedDataFile = fileURL
                                                        isShowingFileSaver = true

                                                    case .failure:
                                                        let message = String(
                                                            format: languageSettings
                                                                .localized("Failed to save file %@"),
                                                            dataFile.fileName
                                                        )
                                                        isShowingFileSaver = false
                                                        Toast.show(message)
                                                    }
                                                }
                                            }
                                        }
                                    )
                                    .background(
                                        FileSaverHandler(
                                            isPresented: $isShowingFileSaver,
                                            fileURL: selectedDataFile,
                                            languageSettings: languageSettings,
                                            onComplete: {
                                                viewModel.removeSavedFilesDirectory()
                                            },
                                            isFileSaved: $isFileSaved
                                        )
                                    )
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
                                leftButtonLabel: "Add more files",
                                leftButtonAccessibilityLabel: "Add more files",
                                leftButtonAction: {
                                    // TODO: Implement add more files functionality
                                },

                                rightButtonIconName: "ic_m3_stylus_note_48pt_wght400",
                                rightButtonLabel: "Sign",
                                rightButtonAccessibilityLabel: "Sign",
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
            Toast.show(languageSettings.localized(error))
        }
    }
}

#Preview {
    SigningView()
        .environmentObject(
            Container.shared.languageSettings()
        )
}
