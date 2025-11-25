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

struct AccessibilityText: View {
    @AppTheme private var theme
    @AppTypography private var typography

    @EnvironmentObject private var languageSettings: LanguageSettings

    let text: String
    var isUrl: Bool = false
    var bottomPadding: CGFloat = Dimensions.Padding.SPadding
    var isTitle: Bool = false

    var body: some View {
        if isUrl {
            if let url = URL(string: text) {
                Link(destination: url) {
                    Text(text)
                        .underline(true, color: theme.primary)
                        .foregroundStyle(theme.primary)
                        .multilineTextAlignment(.leading)
                        .padding(.bottom, bottomPadding)
                }
                .accessibilityLabel(Text(verbatim: "\(languageSettings.localized("Open Button")) \(text)"))
            }
        } else {
            if isTitle {
                Text(text)
                    .font(typography.titleLarge)
                    .foregroundStyle(theme.onSurface)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, bottomPadding)
                    .accessibilityHeading(.h1)
                    .accessibilityAddTraits([.isHeader])
            } else {
                Text(text)
                    .font(typography.bodyLarge)
                    .foregroundStyle(theme.onSurface)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, bottomPadding)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(
        content: {
            AccessibilityText(
                text: "I am a title",
                isTitle: true
            )
            AccessibilityText(text: "I am text")
            AccessibilityText(
                text: "I am a link",
                isUrl: true
            )
        }
    )
    .environmentObject(Container.shared.languageSettings())
    .environmentObject(Container.shared.themeSettings())
}
