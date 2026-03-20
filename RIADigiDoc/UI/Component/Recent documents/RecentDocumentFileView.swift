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

struct RecentDocumentFileView: View {
    @Environment(LanguageSettings.self) private var languageSettings

    @AppTheme private var theme
    @AppTypography private var typography

    let file: FileItem
    let fileIndex: Int

    let onOpenContainer: () -> Void
    let onRemoveContainer: () -> Void

    var body: some View {
        HStack(spacing: Dimensions.Padding.MSPadding) {
            Image("ic_m3_folder_48pt_wght400")
                .resizable()
                .scaledToFit()
                .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                .foregroundStyle(theme.onSurface)
                .accessibilityHidden(true)

            Button(
                action: onOpenContainer,
                label: {
                    Text(verbatim: file.name)
                        .font(typography.titleMedium)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(4)
                        .truncationMode(.middle)
                        .multilineTextAlignment(TextAlignment.leading)
                        .accessibilityLabel(
                            Text(
                                verbatim: "\(languageSettings.localized("File")) " +
                                "\(fileIndex + 1), \(file.name.lowercased())"
                            )
                        )
                }
            )

            Spacer()

            Button(
                action: onRemoveContainer,
                label: {
                    Image("ic_m3_delete_48pt_wght400")
                        .resizable()
                        .scaledToFit()
                        .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                        .foregroundStyle(theme.onSurface)
                        .accessibilityLabel(
                            Text(verbatim: languageSettings.localized("Remove container"))
                        )
                })
        }
    }
}

#Preview {
    RecentDocumentFileView(
        file: FileItem(
            name: "test.asice",
            url: URL(fileURLWithPath: "/path/test.asice"),
            lastOpened: Date.now
        ),
        fileIndex: 0,
        onOpenContainer: {},
        onRemoveContainer: {}
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
