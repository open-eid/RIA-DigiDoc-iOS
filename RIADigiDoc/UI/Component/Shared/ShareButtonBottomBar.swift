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

            if #available(iOS 16.0, *) {
                ShareLink(item: containerUrl) {
                    ShareButton(
                        iconName: iconName,
                        label: label,
                        accessibilityLabel: accessibilityLabel,
                        onClick: {
                            // ShareLink handles sharing
                        }
                    )
                }
            } else {
                ShareButton(
                    iconName: iconName,
                    label: label,
                    accessibilityLabel: accessibilityLabel,
                    onClick: {
                        showingShareSheet = true
                    }
                )
            }
        }
        .padding(.horizontal, Dimensions.Padding.SPadding)
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
    .environmentObject(Container.shared.themeSettings())
}
