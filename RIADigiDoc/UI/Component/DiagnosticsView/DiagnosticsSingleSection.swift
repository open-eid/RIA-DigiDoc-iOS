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

import FactoryKit
import SwiftUI

struct DiagnosticsSingleSection: View {
    @AppTheme private var theme
    @AppTypography private var typography

    let title: String
    let contentLines: [String]
    let identifier: String
    var showDivider: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: Dimensions.Padding.XXSPadding) {
            VStack(alignment: .leading, spacing: Dimensions.Padding.XSPadding) {
                Text(verbatim: title)
                    .foregroundStyle(theme.onSurface)
                    .font(typography.titleMedium)

                if #available(iOS 26.0, *) {
                    ForEach(contentLines.enumerated(), id: \.offset) { index, line in
                        Text(verbatim: line)
                            .font(typography.bodyMedium)
                            .foregroundColor(theme.onSurfaceVariant)
                            .accessibilityIdentifier("\(identifier)-\(index + 1)")
                    }
                } else {
                    ForEach(Array(contentLines.enumerated()), id: \.offset) { index, line in
                        Text(verbatim: line)
                            .font(typography.bodyMedium)
                            .foregroundColor(theme.onSurfaceVariant)
                            .accessibilityIdentifier("\(identifier)-\(index + 1)")
                    }
                }
            }

            if showDivider {
                Divider()
                    .padding(.top, Dimensions.Padding.XSPadding)
            }
        }
        .padding(.top, Dimensions.Padding.XSPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Initializer for String input
extension DiagnosticsSingleSection {
    init(title: String, content: String, identifier: String, showDivider: Bool = true) {
        self.title = title
        self.contentLines = content.components(separatedBy: .newlines)
        self.identifier = identifier
        self.showDivider = showDivider
    }
}

// MARK: - Preview
#Preview {
    VStack {
        DiagnosticsSingleSection(
            title: "Section with Array",
            contentLines: ["Line 1", "Line 2", "Line 3"],
            identifier: "sectionWithArray"
        )

        DiagnosticsSingleSection(
            title: "Section with String",
            content: "Line 1\nLine 2\nLine 3",
            identifier: "sectionWithString"
        )

        DiagnosticsSingleSection(
            title: "Section with String",
            content: "Line 1",
            identifier: "sectionWithString"
        )
    }
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
