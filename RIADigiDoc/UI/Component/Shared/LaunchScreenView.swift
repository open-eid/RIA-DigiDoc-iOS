// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
