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

struct LaunchScreenView: View {
    @AppTheme private var theme
    @AppTypography private var typography
    @Environment(LanguageSettings.self) private var languageSettings

    private var appName: String {
        languageSettings.localized("App name")
    }

    var body: some View {
        ZStack {
            AppColors.initialLaunchScreenBackground.ignoresSafeArea()
            VStack(spacing: Dimensions.Padding.ZeroPadding) {
                Image("image_eesti_shield")
                    .resizable()
                    .scaledToFit()
                    .frame(height: Dimensions.Icon.IconSizeXXL)
                    .accessibilityLabel(appName.lowercased())

                Text(appName.uppercased())
                    .font(typography.headlineMedium)
                    .foregroundStyle(Color.white)
                    .accessibilityLabel(appName.lowercased())
                    .scaleEffect(
                        x: Dimensions.Scaling.SmallScaling,
                        y: Dimensions.Scaling.DefaultScaling
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    LaunchScreenView()
        .environment(Container.shared.themeSettings())
        .environment(Container.shared.languageSettings())
}
