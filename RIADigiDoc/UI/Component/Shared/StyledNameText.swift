import SwiftUI
import UtilsLib

struct StyledNameText: View {
    @AppTheme private var theme
    @AppTypography private var typography

    let name: String
    var allCaps: Bool = false

    var body: some View {
        let finalName = allCaps ? name.uppercased() : name
        let nameParts = finalName.components(separatedBy: ", ").map { $0.trimmingCharacters(in: .whitespaces) }

        HStack(spacing: 0) {
            if nameParts.count == 2 {
                Text(nameParts[0])
                    .fontWeight(.bold)
                Text(verbatim: ", \(nameParts[1])")
            } else {
                Text(finalName)
                    .fontWeight(.bold)
            }
        }
        .foregroundStyle(theme.onSurface)
        .font(typography.bodyLarge)
    }
}
