import SwiftUI
import LibdigidocLibSwift
import UtilsLib

struct SigningView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppTheme private var theme
    @AppTypography private var typography
    @EnvironmentObject private var languageSettings: LanguageSettings

    private let nameUtil: NameUtilProtocol
    private let signatureUtil: SignatureUtilProtocol

    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0

    @State private var selectedSignature: SignatureWrapper?

    @StateObject private var viewModel: SigningViewModel
    @State private var tempContainerURL: URL?
    @State private var isShowingFileSaver = false
    @State private var isFileSaved: Bool = false

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
        viewModel: SigningViewModel = AppAssembler.shared.resolve(SigningViewModel.self)
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        nameUtil = UtilsLibAssembler.shared.resolve(NameUtilProtocol.self)
        signatureUtil = AppAssembler.shared.resolve(SignatureUtilProtocol.self)
    }

    var body: some View {
        TopBarContainer(
            title: containerFilesTitle,
            onLeftClick: { dismiss() },
            content: {
                VStack(alignment: .leading, spacing: Dimensions.Padding.ZeroPadding) {
                    VStack {
                        ContainerNameView(
                            icon: "ic_m3_stylus_note_48pt_wght400",
                            containerNameTitle: containerNameTitle,
                            name: viewModel.containerName,
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
                                Task {
                                    tempContainerURL = viewModel.createCopyOfContainerForSaving(
                                        containerURL: viewModel.containerURL
                                    )

                                    if viewModel.checkIfContainerFileExists(fileLocation: tempContainerURL) {
                                        isShowingFileSaver = true
                                    }
                                }
                            }
                        ).fileMover(isPresented: $isShowingFileSaver, file: tempContainerURL) { result in
                            switch result {
                            case .success:
                                isFileSaved = true
                                Toast.show(languageSettings.localized("File saved"))
                            case .failure:
                                isFileSaved = false
                                Toast.show(languageSettings.localized("Failed to save file"))
                            }
                            isShowingFileSaver = false
                            viewModel.removeSavedFilesDirectory()
                        }

                        if isSignedContainer {
                            TabView(selectedTab: $selectedTab, titles: [
                                containerFilesTitle,
                                containerSignaturesTitle
                            ]) {
                                if selectedTab == 0 {
                                    DataFilesListView(
                                        dataFiles: viewModel.dataFiles,
                                        showRemoveFileButton: !viewModel.isSigned()
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
                                    showRemoveFileButton: !viewModel.isSigned()
                                )
                            }
                            .padding(.vertical, Dimensions.Padding.MPadding)
                        }
                    }
                    .padding(Dimensions.Padding.SPadding)

                    if isSignedContainer {
                        ShareButtonBottomBar(
                            iconName: "ic_m3_ios_share_48pt_wght400",
                            label: shareTitle,
                            accessibilityLabel: shareTitle,
                            onShare: {
                                // TODO: Implement sharing functionality
                            }
                        )
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
                            signedContainer: viewModel.sharedContainerViewModel.getSignedContainer()
                        )
                    }
                }
            })
    }
}

#Preview {
    SigningView()
}
