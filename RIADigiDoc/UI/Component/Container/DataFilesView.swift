import SwiftUI
import LibdigidocLibSwift

struct DataFilesView: View {
    @EnvironmentObject private var languageSettings: LanguageSettings
    @AppTheme private var theme
    @AppTypography private var typography

    @State private var showBottomSheetFromButton = false
    @State private var showBottomSheetFromTap = false

    private var bottomSheetActions: [BottomSheetButton] {
        [
            BottomSheetButton(
                icon: "ic_m3_edit_48pt_wght400",
                title: languageSettings.localized("Open file"),
                accessibilityLabel: languageSettings.localized("Open file").lowercased(),
                onClick: {
                    // TODO: Implement open file action
                }
            ),
            BottomSheetButton(
                icon: "ic_m3_download_48pt_wght400",
                title: languageSettings.localized("Save file"),
                accessibilityLabel: languageSettings.localized("Save file").lowercased(),
                onClick: {
                    // TODO: Implement save file action
                }
            ),
            BottomSheetButton(
                showButton: showRemoveFileButton,
                icon: "ic_m3_encrypted_48pt_wght400",
                title: languageSettings.localized("Remove file"),
                accessibilityLabel: languageSettings.localized("Remove file").lowercased(),
                onClick: {
                    // TODO: Implement remove file action
                }
            )
        ]
    }

    let dataFile: DataFileWrapper
    let showRemoveFileButton: Bool

    var body: some View {
        VStack {
            HStack {
                Image("ic_m3_attach_file_48pt_wght400")
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                    .foregroundStyle(theme.onSurface)
                    .padding(.trailing, Dimensions.Padding.SPadding)
                    .accessibilityHidden(true)

                Text(verbatim: dataFile.fileName)
                    .font(typography.titleMedium)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(4)
                    .multilineTextAlignment(TextAlignment.leading)

                Spacer()

                Button(action: {
                    showBottomSheetFromButton = true
                }, label: {
                    Image("ic_m3_more_vert_48pt_wght400")
                        .resizable()
                        .scaledToFit()
                        .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                        .foregroundStyle(theme.onBackground)
                        .accessibilityLabel("More options")
                })
                .bottomSheet(isPresented: $showBottomSheetFromButton, actions: bottomSheetActions)
            }
            .padding(Dimensions.Padding.MSPadding)
        }
        .listRowInsets(EdgeInsets())
        .onTapGesture {
            showBottomSheetFromTap = true
        }
        .accessibilityAddTraits([.isButton])
        .bottomSheet(isPresented: $showBottomSheetFromTap, actions: bottomSheetActions)
    }
}
