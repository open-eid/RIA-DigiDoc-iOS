// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit

struct LoadingView: View {
    @Environment(LanguageSettings.self) private var languageSettings

    @State private var isLoading: Bool = false
    @State private var rotationAngle: Double = 0

    var body: some View {
        ZStack {
            Image("Spinner")
                .resizable()
                .frame(width: 100, height: 100)
                .rotationEffect(.degrees(rotationAngle))
                .accessibilityLabel(languageSettings.localized("Loading"))
                .onChange(of: isLoading) {
                    withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                        rotationAngle += 360
                    }
                }
                .onAppear {
                    isLoading = true
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    LoadingView()
        .environment(Container.shared.languageSettings())
        .environment(Container.shared.themeSettings())
}
