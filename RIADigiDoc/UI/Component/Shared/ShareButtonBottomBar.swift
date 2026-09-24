// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit

struct ShareButtonBottomBar: View {
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled

    @AppTheme private var theme
    @AppTypography private var typography

    @State private var showingShareSheet = false

    let iconName: String
    let label: String
    let accessibilityLabel: String
    let containerUrl: URL

    var body: some View {
        HStack {
            Spacer()

            ShareLink(item: containerUrl) {
                ShareButton(
                    iconName: iconName,
                    label: label,
                    accessibilityLabel: accessibilityLabel
                )
            }
        }
        .padding(.horizontal, Dimensions.Padding.MPadding)
        .padding(.top, Dimensions.Padding.XSPadding)
        .padding(.bottom, Dimensions.Padding.SPadding)
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [containerUrl])
        }
        .accessibilityIdentifier("signedContainerContainer")
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    let activities: [UIActivity]? = nil

    func makeUIViewController(context _: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: activities)
    }

    func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}

#Preview {
    ShareButtonBottomBar(
        iconName: "ic_m3_ios_share_48pt_wght400",
        label: "Share",
        accessibilityLabel: "Share",
        containerUrl: URL(fileURLWithPath: "")
    )
    .environment(Container.shared.themeSettings())
}
