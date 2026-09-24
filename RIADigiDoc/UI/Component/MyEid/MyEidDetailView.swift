// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit

struct MyEidDataItem {
    let title: String
    let value: String
    let status: MyEidDocumentStatus?
    let spellOutCharacters: Bool

    init(
        title: String,
        value: String,
        status: MyEidDocumentStatus? = nil,
        spellOutCharacters: Bool = false
    ) {
        self.title = title
        self.value = value
        self.status = status
        self.spellOutCharacters = spellOutCharacters
    }
}

struct MyEidDetailView: View {
    @Environment(LanguageSettings.self) private var languageSettings

    @AppTheme private var theme
    @AppTypography private var typography

    let myEidDataItem: MyEidDataItem

    private var tagBackgroundColor: Color {
        myEidDataItem.status == .valid ? theme.successContainer : theme.errorContainer
    }

    private var tagContentColor: Color {
        myEidDataItem.status == .valid ? theme.onSuccessContainer : theme.onErrorContainer
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
                            .accessibilityLabel(myEidDataItem.title.lowercased())
                        Text(verbatim: myEidDataItem.value)
                            .foregroundStyle(theme.onSurface)
                            .font(typography.bodyLarge)
                            .accessibilityLabel(myEidDataItem.value.lowercased())
                            .speechSpellsOutCharacters(myEidDataItem.spellOutCharacters)
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
