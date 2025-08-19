import FactoryKit
import SwiftUI

struct DiagnosticsSingleSection: View {
    @AppTheme private var theme
    @AppTypography private var typography

    let title: String
    let contentLines: [String]
    var showDivider: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: Dimensions.Padding.XXSPadding) {
            VStack(alignment: .leading, spacing: Dimensions.Padding.XSPadding) {
                Text(verbatim: title)
                    .foregroundStyle(theme.onSurface)
                    .font(typography.titleMedium)

                ForEach(contentLines, id: \.self) { line in
                    Text(verbatim: line)
                        .font(typography.bodyMedium)
                        .foregroundColor(theme.onSurfaceVariant)
                }
            }

            if showDivider {
                Divider()
                    .padding(.top, Dimensions.Padding.XSPadding)
            }
        }
        .padding(.top, Dimensions.Padding.XSPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Initializer for String input
extension DiagnosticsSingleSection {
    init(title: String, content: String, showDivider: Bool = true) {
        self.title = title
        self.contentLines = content.components(separatedBy: .newlines)
        self.showDivider = showDivider
    }
}

// MARK: - Preview
#Preview {
    VStack {
        DiagnosticsSingleSection(
            title: "Section with Array",
            contentLines: ["Line 1", "Line 2", "Line 3"]
        )

        DiagnosticsSingleSection(
            title: "Section with String",
            content: "Line 1\nLine 2\nLine 3"
        )

        DiagnosticsSingleSection(
            title: "Section with String",
            content: "Line 1"
        )
    }
}
