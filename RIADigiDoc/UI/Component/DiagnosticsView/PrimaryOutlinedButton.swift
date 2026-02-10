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

struct PrimaryOutlinedButton: View {
    @AppTheme private var theme
    @AppTypography private var typography

    let text: String
    let assetImageName: String?
    let isButtonEnabled: Bool
    let action: () -> Void

    init(
        text: String,
        assetImageName: String?,
        isButtonEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.text = text
        self.assetImageName = assetImageName
        self.isButtonEnabled = isButtonEnabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack {
                if let image = assetImageName {
                    Image(image)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(theme.primary)
                        .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                        .accessibilityHidden(true)
                }
                Text(verbatim: text)
                    .foregroundStyle(isButtonEnabled ? theme.primary : theme.surfaceContainerHighest)
                    .font(typography.labelLarge)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(height: Dimensions.Icon.IconSizeXXS)
                    .padding(Dimensions.Padding.XSPadding)
            }
            .frame(maxWidth: .infinity)
            .background(
                Capsule()
                    .fill(isButtonEnabled ? theme.surface : Color.gray)
            )
            .overlay(
                Capsule()
                    .stroke(theme.outline, lineWidth: Dimensions.Height.XSBorder)
            )
        }
        .disabled(!isButtonEnabled)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: Dimensions.Padding.XSPadding) {
        PrimaryOutlinedButton(
            text: "button without icon",
            assetImageName: nil,
            action: {}
        )
        PrimaryOutlinedButton(
            text: "button with icon",
            assetImageName: "ic_m3_download_48pt_wght400",
            action: {}
        )
    }
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
