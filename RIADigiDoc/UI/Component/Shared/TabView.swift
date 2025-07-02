import SwiftUI

struct TabView<Content: View>: View {
    @AppTheme private var theme
    @AppTypography private var typography

    @Binding var selectedTab: Int
    let titles: [String]
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack {
            HStack {
                ForEach(titles.indices, id: \.self) { index in
                    Button(action: {
                        withAnimation {
                            selectedTab = index
                        }
                    }, label: {
                        VStack {
                            Text(titles[index])
                                .font(typography.labelLarge)
                                .foregroundStyle(selectedTab == index ? theme.primary : theme.onSurface)
                            Rectangle()
                                .fill(selectedTab == index ? theme.primary : theme.outlineVariant)
                                .frame(height: Dimensions.Height.SBorder)
                        }
                        .frame(maxWidth: .infinity)
                    })
                }
            }
            .padding(.top, Dimensions.Padding.LPadding)

            content()
        }
    }
}

#Preview {
    TabView(selectedTab: .constant(0), titles: ["Tab 1", "Tab 2"]) {
        EmptyView()
    }
}
