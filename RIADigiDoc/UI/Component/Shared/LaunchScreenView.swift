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

struct LaunchScreenView: View {
    private static let spinnerDelay: Duration = .seconds(3)

    @AppTheme private var theme
    @AppTypography private var typography
    @Environment(LanguageSettings.self) private var languageSettings

    @State private var rotationAngle: Double = 0
    @State private var isSpinnerVisible = false

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

                if isSpinnerVisible {
                    spinner
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
        .task {
            try? await Task.sleep(for: Self.spinnerDelay)
            isSpinnerVisible = true
        }
    }

    private var spinner: some View {
        Image("Spinner")
            .resizable()
            .renderingMode(.template)
            .foregroundStyle(Color.white)
            .frame(width: Dimensions.Icon.IconSizeXS, height: Dimensions.Icon.IconSizeXS)
            .rotationEffect(.degrees(rotationAngle))
            .padding(.top, Dimensions.Padding.LPadding)
            .accessibilityLabel(languageSettings.localized("Loading"))
            .onAppear {
                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                    rotationAngle = 360
                }
            }
    }
}

#Preview {
    LaunchScreenView()
        .environment(Container.shared.themeSettings())
        .environment(Container.shared.languageSettings())
}
