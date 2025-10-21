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

struct TabView<Content: View>: View {
    @AppTheme private var theme
    @AppTypography private var typography

    @Binding var selectedTab: Int
    let titles: [String]
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack {
            HStack {
                ForEach(titles.indices, id: \.self) { index in
                    Button(action: {
                        withAnimation {
                            selectedTab = index
                        }
                    }, label: {
                        VStack {
                            Text(titles[index])
                                .font(typography.labelLarge)
                                .foregroundStyle(selectedTab == index ? theme.primary : theme.onSurface)
                            Rectangle()
                                .fill(selectedTab == index ? theme.primary : theme.outlineVariant)
                                .frame(height: Dimensions.Height.SBorder)
                        }
                        .frame(maxWidth: .infinity)
                    })
                }
            }
            .padding(.top, Dimensions.Padding.LPadding)

            content()
        }
    }
}

#Preview {
    TabView(selectedTab: .constant(0), titles: ["Tab 1", "Tab 2"]) {
        EmptyView()
    }
    .environmentObject(Container.shared.themeSettings())
}
