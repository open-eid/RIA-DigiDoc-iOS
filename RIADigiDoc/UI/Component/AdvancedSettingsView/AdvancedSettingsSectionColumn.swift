import SwiftUI
import FactoryKit

struct AdvancedSettingsSectionColumn<Content: View>: View {
    @AppTheme private var theme
    @AppTypography private var typography

    var title: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: Dimensions.Padding.ZeroPadding) {
                Text(title)
                    .font(typography.titleLarge)
                    .foregroundStyle(theme.onSurfaceVariant)
                    .padding(.vertical, Dimensions.Padding.SPadding)

                content()
            }
    }
}

// MARK: - Preview
#Preview {
    AdvancedSettingsSectionColumn(
        title: "Title"
    ) {
        AdvancedSettingsLinkRow(
            label: "Row title",
            onClick: {}
        )
    }
    .environmentObject(Container.shared.themeSettings())
}
