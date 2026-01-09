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

struct MyEidDataItem {
    let title: String
    let value: String
    let status: MyEidDocumentStatus?

    init(title: String, value: String, status: MyEidDocumentStatus? = nil) {
        self.title = title
        self.value = value
        self.status = status
    }
}

struct MyEidDetailView: View {
    @Environment(LanguageSettings.self) private var languageSettings

    @AppTheme private var theme
    @AppTypography private var typography

    let myEidDataItem: MyEidDataItem

    private var tagBackgroundColor: Color {
        myEidDataItem.status == .valid ? AppColors.Green50 : AppColors.Red50
    }

    private var tagContentColor: Color {
        myEidDataItem.status == .valid ? AppColors.Green700 : AppColors.Red800
    }

    var body: some View {
        VStack {
            Grid(
                horizontalSpacing: Dimensions.Padding.XXSPadding,
                verticalSpacing: Dimensions.Padding.XXSPadding
            ) {
                GridRow {
                    VStack(alignment: .leading, spacing: Dimensions.Padding.XXSPadding) {
                        Text(verbatim: myEidDataItem.title)
                            .font(typography.labelSmall)
                            .foregroundStyle(theme.onSurfaceVariant)
                        Text(verbatim: myEidDataItem.value)
                            .foregroundStyle(theme.onSurface)
                            .font(typography.bodyLarge)
                    }

                    Spacer()

                    if let status = myEidDataItem.status {
                        TagBadge(
                            text: languageSettings.localized(status.localizationKey),
                            tagBackgroundColor: tagBackgroundColor,
                            tagContentColor: tagContentColor
                        )
                    }
                }
            }
            .contentShape(Rectangle())
            .padding(.vertical, Dimensions.Padding.XSPadding)
            .accessibilityElement(children: .combine)

            Divider()
        }
    }
}

#Preview {
    MyEidDetailView(
        myEidDataItem: MyEidDataItem(
            title: "Data item",
            value: "Details",
            status: .valid
        )
    )
    .environment(Container.shared.themeSettings())
}
