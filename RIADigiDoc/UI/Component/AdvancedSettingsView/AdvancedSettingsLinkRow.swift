import SwiftUI
import FactoryKit

struct AdvancedSettingsLinkRow: View {
    @AppTheme private var theme
    @AppTypography private var typography

    var label: String
    var onClick: () -> Void

    var body: some View {
        Button(
            action: onClick
        ) {
            HStack {
                Text(label)
                    .font(typography.bodyLarge)
                    .foregroundStyle(theme.onSurface)
                Spacer()
                Image("ic_m3_arrow_right_48pt_wght400")
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                    .foregroundStyle(theme.onSurface)
                    .accessibilityLabel(label.lowercased())
            }
            .contentShape(Rectangle())
            .padding(.vertical, Dimensions.Padding.SPadding)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    AdvancedSettingsLinkRow(
        label: "Row title",
        onClick: {}
    )
    .environmentObject(Container.shared.themeSettings())
}
