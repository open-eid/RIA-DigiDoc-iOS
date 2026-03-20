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
