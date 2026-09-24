// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit

struct AdvancedSettingsSectionColumn<Content: View>: View {
    @AppTheme private var theme
    @AppTypography private var typography

    var title: String
    var isScrollable: Bool = true

    @ViewBuilder var content: () -> Content

    var body: some View {
        Group {
            if isScrollable {
                ScrollView {
                    columnContent()
                }
            } else {
                columnContent()
            }
        }
    }

    @ViewBuilder
    private func columnContent() -> some View {
        VStack(
            alignment: .leading,
            spacing: Dimensions.Padding.ZeroPadding,
            content: {
                Text(title)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(typography.titleLarge)
                    .foregroundStyle(theme.onSurfaceVariant)
                    .padding(.vertical, Dimensions.Padding.SPadding)
                    .accessibilityHeading(.h1)
                    .accessibilityAddTraits([.isHeader])

                content()
            }
        )
    }
}

// MARK: - Preview
#Preview {
    AdvancedSettingsSectionColumn(
        title: "Title"
    ) {
        AdvancedSettingsLinkRow(
            label: "Row title",
            onClick: {}
        )
    }
    .environment(Container.shared.themeSettings())
}
