import SwiftUI
import FactoryKit

struct InfoHeader: View {
    var body: some View {
        HStack(spacing: Dimensions.Padding.MPadding) {
            InfoHeaderLogoComponent()
            InfoHeaderTextComponent()
        }
        .padding(.vertical, Dimensions.Padding.XSPadding)
        .padding(.horizontal, Dimensions.Padding.SPadding)
    }
}

// MARK: - Preview
#Preview {
    InfoHeader()
        .environmentObject(
            Container.shared.languageSettings()
        )
}
