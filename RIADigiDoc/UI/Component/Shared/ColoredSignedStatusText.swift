import SwiftUI
import LibdigidocLibSwift

struct ColoredSignedStatusText: View {
    @AppTheme private var theme
    @AppTypography private var typography

    let text: String
    let status: SignatureStatus

    private var isSignatureValidOrWarning: Bool {
        status == .valid || status == .warning || status == .nonQSCD
    }

    private var tagBackgroundColor: Color {
        isSignatureValidOrWarning ? AppColors.Green50 : AppColors.Red50
    }

    private var tagContentColor: Color {
        isSignatureValidOrWarning ? AppColors.Green700 : AppColors.Red800
    }

    private var additionalTextColor: Color {
        switch status {
        case .valid:
            return AppColors.Red800
        default:
            return AppColors.Yellow800
        }
    }

    var body: some View {
        let parts = text.components(separatedBy: " (")

        HStack {
            Text(parts[0])
                .font(typography.bodyMedium)
                .padding(.horizontal, Dimensions.Padding.XSPadding)
                .padding(.vertical, Dimensions.Padding.XXSPadding)
                .background(tagBackgroundColor)
                .foregroundStyle(tagContentColor)
                .clipShape(Capsule())

            if parts.count > 1 {
                Text(verbatim: "(\(parts[1])")
                    .font(typography.bodyMedium)
                    .foregroundStyle(additionalTextColor)
            }
        }
    }
}

#Preview {
    ColoredSignedStatusText(
        text: "Signature is valid",
        status: .valid
    )

    ColoredSignedStatusText(
        text: "Signature is valid (warnings)",
        status: .warning
    )

    ColoredSignedStatusText(
        text: "Signature is unknown",
        status: .unknown
    )
}
