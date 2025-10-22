import SwiftUI
import CommonsLib

struct RenameModalView: View {
    @EnvironmentObject private var languageSettings: LanguageSettings
    @AppTheme private var theme
    @AppTypography private var typography

    @ObservedObject var signingViewModel: SigningViewModel
    @Binding var showRenameModal: Bool
    @Binding var newContainerName: String

    var body: some View {
        ZStack {
            // Make the background darker to focus on the dialog
            Color.black
                .opacity(Dimensions.Shadow.LOpacity)
                .ignoresSafeArea()

            InputModal(
                icon: "ic_m3_edit_48pt_wght400",
                title: languageSettings.localized("Change container name"),
                placeholder: signingViewModel.containerName,
                text: Binding<String>(
                    get: {
                        URL(fileURLWithPath: signingViewModel.containerName)
                            .deletingPathExtension()
                            .lastPathComponent
                    },
                    set: { newValue in
                        let existingExtension = URL(fileURLWithPath: signingViewModel.containerName).pathExtension
                        let newValueURL = URL(fileURLWithPath: newValue)

                        let containerExtension =
                        existingExtension.isEmpty ? Constants.Extension.Default : existingExtension

                        newContainerName = newValueURL
                            .appendingPathExtension(containerExtension)
                            .lastPathComponent
                    }),
                onConfirm: {
                    showRenameModal = false
                    Task {
                        let uniqueContainerName = await signingViewModel.renameContainer(to: newContainerName)
                        defer { newContainerName = "" }

                        if let uniqueContainerName {
                            signingViewModel.containerName = uniqueContainerName.lastPathComponent
                        }
                    }
                },
                onCancel: {
                    showRenameModal = false
                    newContainerName = ""
                }
            )
        }
    }
}
