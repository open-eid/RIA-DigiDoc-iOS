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

struct ActionButton: View {
    @AppTheme private var theme

    let title: String
    let titleAccessibility: String
    let description: String
    let assetImageName: String
    let action: () -> Void

    init(
        title: String,
        titleAccessibility: String = "",
        description: String,
        assetImageName: String,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.titleAccessibility = titleAccessibility
        self.description = description
        self.assetImageName = assetImageName
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Dimensions.Padding.SPadding) {
                AssetIconComponent(assetName: assetImageName)
                TextComponent(
                    title: title,
                    titleAccessibility: titleAccessibility,
                    description: description
                )
                Spacer()
            }
            .padding(Dimensions.Padding.SPadding)
            .background(theme.surfaceContainerLow)
            .cornerRadius(Dimensions.Corner.MSCornerRadius)

            // MARK: - Elevated Style
            .shadow(
                color: theme.primary,
                radius: Dimensions.Shadow.zeroRadius,
                x: Dimensions.Shadow.xOffset,
                y: Dimensions.Shadow.ySOffset
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(titleAccessibility.isEmpty ? title : titleAccessibility)
    }
}

// MARK: - Asset Icon Component
private struct AssetIconComponent: View {
    @AppTheme private var theme

    let assetName: String

    var body: some View {
        Image(assetName)
            .resizable()
            .scaledToFit()
            .foregroundStyle(theme.onPrimary)
            .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
            .padding(Dimensions.Padding.XSPadding)
            .background(theme.primary)
            .clipShape(Circle())
            .accessibilityHidden(true)
    }
}

// MARK: - Text Component
private struct TextComponent: View {
    @AppTheme private var theme
    @AppTypography private var typography

    let title: String
    let titleAccessibility: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: Dimensions.Padding.XXSPadding) {
            Text(title)
                .font(typography.titleMedium)
                .foregroundStyle(theme.onSurface)
                .accessibilityLabel(titleAccessibility.isEmpty ? title : titleAccessibility)

            Text(description)
                .font(typography.bodyMedium)
                .foregroundStyle(theme.onSurface)
        }
    }
}

// MARK: - Preview
#Preview {
    VStack {
        ActionButton(
            title: "Add Document",
            description: "Do something",
            assetImageName: "ic_m3_attach_file_48pt_wght400",
        ) {}
            .environment(Container.shared.themeSettings())
    }
    .padding()
}
