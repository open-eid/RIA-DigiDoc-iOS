// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
