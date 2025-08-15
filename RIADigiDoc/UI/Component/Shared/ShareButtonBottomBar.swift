import SwiftUI

struct ShareButtonBottomBar: View {
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
}
