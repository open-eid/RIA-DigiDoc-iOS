// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
                .padding(.top, Dimensions.Padding.SPadding)
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
