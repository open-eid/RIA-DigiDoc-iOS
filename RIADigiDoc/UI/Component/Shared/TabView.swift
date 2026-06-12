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

struct TabView<Tab: RawRepresentable, Content: View>: View where Tab.RawValue == Int {
    @Environment(LanguageSettings.self) private var languageSettings
    @AppTheme private var theme
    @AppTypography private var typography

    @Binding var selectedTab: Tab
    let titles: [String]
    @ViewBuilder let content: () -> Content

    private var selectedIndex: Binding<Int> {
        Binding(
            get: { selectedTab.rawValue },
            set: { selectedTab = Tab(rawValue: $0) ?? selectedTab }
        )
    }

    private let tabMinHeight: CGFloat = 56

    var body: some View {
        VStack(spacing: Dimensions.Padding.ZeroPadding) {
            HStack(spacing: Dimensions.Padding.ZeroPadding) {
                ForEach(titles.indices, id: \.self) { index in
                    let title = titles[index]
                    let isSelected = selectedIndex.wrappedValue == index
                    let selectedText = isSelected
                        ? languageSettings.localized("Selected")
                        : languageSettings.localized("Unselected")

                    Button {
                        withAnimation(.easeInOut) {
                            selectedIndex.wrappedValue = index
                        }
                    } label: {
                        Text(verbatim: title)
                            .font(typography.labelLarge)
                            .foregroundStyle(isSelected ? theme.primary : theme.onSurface)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, Dimensions.Padding.XSPadding)
                            .padding(.vertical, Dimensions.Padding.XSPadding)
                            .accessibilityLabel(Text(verbatim:
                                "\(title), " +
                                "\(languageSettings.localized("Tab")) \(index + 1) / \(titles.count), " +
                                "\(selectedText)"
                            ))
                            .accessibilityInputLabels(
                                [Text(verbatim: "Tab \(index + 1)")]
                            )
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, minHeight: tabMinHeight)
                    .accessibilityLabel(titles[index].lowercased())
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .overlay(alignment: .bottom) {
                HStack(spacing: Dimensions.Padding.ZeroPadding) {
                    ForEach(titles.indices, id: \.self) { index in
                        Rectangle()
                            .fill(selectedIndex.wrappedValue == index ? theme.primary : theme.outlineVariant)
                            .frame(height: Dimensions.Height.SBorder)
                    }
                }
            }

            content()
        }
    }
}

#Preview {
    TabView(
        selectedTab: .constant(SigningViewTab.files),
        titles: [
            "Files",
            "Signatures"
        ]
    ) {
        EmptyView()
    }
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
