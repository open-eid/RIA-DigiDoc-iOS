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
import LibdigidocLibSwift
import CommonsLib

struct DataFilesView: View {
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @Environment(LanguageSettings.self) private var languageSettings
    @AppTheme private var theme
    @AppTypography private var typography

    @State private var showBottomSheetFromButton = false
    @State private var showBottomSheetFromTap = false

    @AccessibilityFocusState private var focusedField: AccessibilityField?

    let fileIndex: Int
    let onOpenFileButtonClick: (DataFileWrapper) -> Void
    let onSaveDataFileButtonClick: (DataFileWrapper) -> Void
    let onRemoveFileButtonClick: (DataFileWrapper) -> Void

    let dataFile: DataFileWrapper
    let showRemoveFileButton: Bool
    @Binding var showRemoveDataFileModal: Bool
    var onSelect: (() -> Void)?

    private var bottomSheetActions: [BottomSheetButton] {
        DataFileBottomSheetActions.actions(
            showRemoveFileButton: showRemoveFileButton,
            onOpenFileButtonClick: { onOpenFileButtonClick(dataFile) },
            onSaveFileButtonClick: { onSaveDataFileButtonClick(dataFile) },
            onRemoveFileButtonClick: {
                onSelect?()
                showRemoveDataFileModal = true
            }
        )
    }

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
                    .truncationMode(.middle)
                    .multilineTextAlignment(TextAlignment.leading)
                    .accessibilityLabel(
                        Text(
                            verbatim: "\(languageSettings.localized("File")) " +
                            "\(fileIndex), \(dataFile.fileName.lowercased())"
                        )
                    )

                Spacer()

                Button(action: accessibleAction(
                    voiceOverEnabled: voiceOverEnabled,
                    focusedField: $focusedField
                ) {
                    showBottomSheetFromButton = true
                }, label: {
                    Image("ic_m3_more_vert_48pt_wght400")
                        .resizable()
                        .scaledToFit()
                        .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                        .foregroundStyle(theme.onBackground)
                        .accessibilityLabel(
                            Text(
                                verbatim: "\(languageSettings.localized("File")) " +
                                "\(fileIndex), \(languageSettings.localized("More options"))"
                            )
                        )
                })
                .bottomSheet(isPresented: $showBottomSheetFromButton, actions: bottomSheetActions)
                .accessibilityFocusRestore(
                    focusedField: $focusedField,
                    field: .dataFile(.openDataFileOptionsButton),
                    when: showBottomSheetFromButton
                )
            }
            .padding(Dimensions.Padding.MSPadding)
        }
        .listRowInsets(EdgeInsets())
        .onTapGesture {
            onOpenFileButtonClick(dataFile)
        }
        .accessibilityAddTraits([.isButton])
        .bottomSheet(isPresented: $showBottomSheetFromTap, actions: bottomSheetActions)
    }
}

#Preview {
    DataFilesView(
        fileIndex: 0,
        onOpenFileButtonClick: { _ in },
        onSaveDataFileButtonClick: { _ in },
        onRemoveFileButtonClick: { _ in },
        dataFile: DataFileWrapper(
            fileId: "0",
            fileName: Constants.Container.DefaultName,
            fileSize: 123,
            mediaType: Constants.MimeType.Default
        ),
        showRemoveFileButton: true,
        showRemoveDataFileModal: .constant(false)
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
