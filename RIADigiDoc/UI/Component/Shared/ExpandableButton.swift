import SwiftUI

struct ExpandableButton: View {
    @AppTheme private var theme
    @AppTypography private var typography

    @State private var isExpanded = false

    private let title: String
    private let detailText: String

    init(
        title: String,
        detailText: String,
        isExpanded: Bool = false
    ) {
        self.title = title
        self.detailText = detailText
        self.isExpanded = isExpanded
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Dimensions.Padding.SPadding) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }, label: {
                HStack(spacing: Dimensions.Padding.XXSPadding) {
                    Image(isExpanded ? "ic_m3_arrow_down_48pt_wght400" : "ic_m3_keyboard_arrow_right_48pt_wght400")
                        .resizable()
                        .scaledToFit()
                        .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                        .foregroundStyle(theme.primary)
                        .padding(.trailing, Dimensions.Padding.SPadding)
                        .animation(.smooth, value: isExpanded)
                        .accessibilityHidden(true)

                    Text(verbatim: title)
                        .foregroundStyle(theme.primary)
                        .font(typography.bodyLarge)
                        .accessibilityLabel(title.lowercased())

                    Spacer()
                }
            })

            if isExpanded {
                Text(verbatim: detailText)
                    .foregroundStyle(theme.onSurface)
                    .font(typography.bodyLarge)
                    .animation(.smooth, value: isExpanded)
            }
        }
    }
}

#Preview {
    ExpandableButton(
        title: "Technical information",
        detailText: "Technical information about signature"
    )
}
