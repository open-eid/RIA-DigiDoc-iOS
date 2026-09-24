// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import FactoryKit
import SwiftUI

struct BottomSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageSettings.self) private var languageSettings
    @AppTheme private var theme
    @AppTypography private var typography

    @AccessibilityFocusState private var focusedButtonTitle: String?

    let actions: [BottomSheetButton]

    var body: some View {
        VStack(spacing: Dimensions.Padding.LPadding) {
            HStack {
                Spacer()
                Button(action: { dismiss() }, label: {
                    Image("ic_m3_close_48pt_wght400")
                        .resizable()
                        .scaledToFit()
                        .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                        .foregroundStyle(theme.onSurface)
                        .accessibilityLabel(languageSettings.localized("Close"))
                })
            }
            .padding(Dimensions.Padding.SPadding)

            ForEach(actions) { item in
                if item.showButton {
                    Button(
                        action: {
                            item.onClick()
                            dismiss()
                        },
                        label: {
                            HStack {
                                Image(item.icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                                    .foregroundStyle(theme.onSurface)
                                    .accessibilityHidden(true)

                                Text(languageSettings.localized(item.title))
                                    .foregroundStyle(theme.onSurface)
                                    .font(typography.bodyLarge)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.leading)
                                    .accessibilityLabel(
                                        languageSettings.localized(item.accessibilityLabel).lowercased()
                                    )
                                    .accessibilityAddTraits([.isButton])

                                Spacer()

                                if item.showExtraIcon {
                                    Image(item.extraIcon)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                                        .foregroundStyle(theme.onSurface)
                                        .accessibilityHidden(true)
                                }
                            }
                            .foregroundStyle(theme.onSurface)
                            .padding(.horizontal, Dimensions.Padding.MPadding)
                        })
                    .accessibilityFocused($focusedButtonTitle, equals: item.title)
                }
            }
        }
        .padding(.vertical, Dimensions.Padding.MSPadding)
        .padding(.bottom, Dimensions.Padding.MPadding)
        .frame(maxWidth: .infinity)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                if let firstAction = actions.first(where: { $0.showButton }) {
                    focusedButtonTitle = firstAction.title
                }
            }
        }
    }
}

struct BottomSheetViewModifier: ViewModifier {
    @State private var contentHeight: CGFloat = 0
    @Binding var isPresented: Bool
    let actions: [BottomSheetButton]

    @ViewBuilder
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                BottomSheet(actions: actions)
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    contentHeight = geometry.size.height
                                }
                        }
                    )
                    .presentationDetents([.height(contentHeight)])
                    .presentationDragIndicator(.visible)
            }
    }
}

extension View {
    func bottomSheet(isPresented: Binding<Bool>, actions: [BottomSheetButton]) -> some View {
        self.modifier(BottomSheetViewModifier(isPresented: isPresented, actions: actions))
    }
}

#Preview {
    let sheetActions = [
        BottomSheetButton(
            icon: "ic_m3_edit_48pt_wght400",
            title: "Change container name",
            accessibilityLabel: "Change container name",
            onClick: {}
        ),
        BottomSheetButton(
            icon: "ic_m3_download_48pt_wght400",
            title: "Save container",
            accessibilityLabel: "Save container",
            onClick: {}
        )
    ]
    Button("Show Sheet") {}
        .bottomSheet(isPresented: .constant(true), actions: sheetActions)
        .environment(Container.shared.languageSettings())
        .environment(Container.shared.themeSettings())
}
