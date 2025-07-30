import SwiftUI

struct SignatureDataItem {
    let title: String
    let value: String
    let extraIcon: String?

    init(title: String, value: String, extraIcon: String? = nil) {
        self.title = title
        self.value = value
        self.extraIcon = extraIcon
    }
}

struct SignerDetailView: View {
    @AppTheme private var theme
    @AppTypography private var typography

    let signatureDataItem: SignatureDataItem

    var body: some View {
        if #available(iOS 16.0, *) {
            VStack {
                Grid(horizontalSpacing: Dimensions.Padding.XXSPadding, verticalSpacing: Dimensions.Padding.XXSPadding) {

                    GridRow {
                        VStack(alignment: .leading, spacing: Dimensions.Padding.XXSPadding) {
                            Text(verbatim: signatureDataItem.title)
                                .font(typography.labelSmall)
                                .foregroundStyle(theme.onSurfaceVariant)
                            Text(verbatim: signatureDataItem.value)
                                .foregroundStyle(theme.onSurface)
                                .font(typography.bodyLarge)
                        }

                        Spacer()

                        if let extraIcon = signatureDataItem.extraIcon {
                            Image(extraIcon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                                .foregroundStyle(theme.onBackground)
                                .accessibilityHidden(true)
                        }
                    }
                }
                .contentShape(Rectangle())
                .padding(.vertical, Dimensions.Padding.XSPadding)

                Divider()
            }
        } else {
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: Dimensions.Padding.XXSPadding) {
                        Text(verbatim: signatureDataItem.title)
                            .font(typography.labelSmall)
                            .foregroundStyle(theme.onSurfaceVariant)
                        Text(verbatim: signatureDataItem.value)
                            .foregroundStyle(theme.onSurface)
                            .font(typography.bodyLarge)
                    }

                    Spacer()


                    if let extraIcon = signatureDataItem.extraIcon {
                        Image(extraIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                            .foregroundStyle(theme.onBackground)
                            .accessibilityHidden(true)
                    }
                }
                .padding(.vertical, Dimensions.Padding.XSPadding)
            }

            Divider()
        }
    }
}


#Preview {
    SignerDetailView(
        signatureDataItem:
            SignatureDataItem(
                title: "Signer's certificate issuer:",
                value: "Test user, 12345678900",
                extraIcon: "ic_m3_arrow_right_48pt_wght400"
            )
    )
}
