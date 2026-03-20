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
