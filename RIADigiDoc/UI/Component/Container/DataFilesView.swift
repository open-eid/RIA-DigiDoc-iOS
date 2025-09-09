import SwiftUI
import LibdigidocLibSwift

struct DataFilesView: View {
    @EnvironmentObject private var languageSettings: LanguageSettings
    @AppTheme private var theme
    @AppTypography private var typography

    @State private var showBottomSheetFromButton = false
    @State private var showBottomSheetFromTap = false

    let onOpenFileButtonClick: (DataFileWrapper) -> Void
    let onSaveDataFileButtonClick: (DataFileWrapper) -> Void

    private var bottomSheetActions: [BottomSheetButton] {
        DataFileBottomSheetActions.actions(
            showRemoveFileButton: showRemoveFileButton,
            onOpenFileButtonClick: { onOpenFileButtonClick(dataFile) },
            onSaveFileButtonClick: { onSaveDataFileButtonClick(dataFile) }
        )
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
