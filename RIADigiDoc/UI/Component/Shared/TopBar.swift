import SwiftUI

struct TopBarContainer<Content: View>: View {
    @EnvironmentObject private var languageSettings: LanguageSettings

    var title: String?

    var leftIcon: String = "ic_m3_arrow_back_ios_48pt_wght400"
    var leftIconAccessibility: String = "Back"
    var onLeftClick: (() -> Void)? = {}

    var rightPrimaryIcon: String = "ic_m3_help_48pt_wght400"
    var rightPrimaryIconAccessibility: String = "Help"
    var onRightPrimaryClick: (() -> Void)? = {}

    var rightSecondaryIcon: String = "ic_m3_settings_48pt_wght400"
    var rightSecondaryIconAccessibility: String = "Settings"
    var onRightSecondaryClick: () -> Void = {}

    var extraButtonIcon: String = "ic_m3_notifications_48pt_wght400"
    var extraButtonIconAccessibility: String = "Notifications"
    var onExtraButtonClick: () -> Void = {}
    var showExtraButton: Bool = false
    var extraBadgeCount: Int = 0

    var showRightIcons: Bool = true

    let content: () -> Content

    var body: some View {
        VStack(spacing: Dimensions.Padding.ZeroPadding) {
            TopBar(
                title: title,
                leftIcon: leftIcon,
                leftIconAccessibility: leftIconAccessibility,
                onLeftClick: onLeftClick ?? {},

                rightPrimaryIcon: rightPrimaryIcon,
                rightPrimaryIconAccessibility: rightPrimaryIconAccessibility,
                onRightPrimaryClick: onRightPrimaryClick,

                rightSecondaryIcon: rightSecondaryIcon,
                rightSecondaryIconAccessibility: rightSecondaryIconAccessibility,
                onRightSecondaryClick: onRightSecondaryClick,

                extraButtonIcon: extraButtonIcon,
                extraButtonIconAccessibility: extraButtonIconAccessibility,
                onExtraButtonClick: onExtraButtonClick,
                showExtraButton: showExtraButton,
                extraBadgeCount: extraBadgeCount,

                showRightIcons: showRightIcons
            )
            content()
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

struct TopBar: View {
    @AppTheme private var theme
    @AppTypography private var typography
    @EnvironmentObject private var languageSettings: LanguageSettings

    var title: String?

    var leftIcon: String
    var leftIconAccessibility: String
    var onLeftClick: () -> Void = {}

    var rightPrimaryIcon: String
    var rightPrimaryIconAccessibility: String
    var onRightPrimaryClick: (() -> Void)?

    var rightSecondaryIcon: String
    var rightSecondaryIconAccessibility: String
    var onRightSecondaryClick: () -> Void = {}

    var extraButtonIcon: String
    var extraButtonIconAccessibility: String
    var onExtraButtonClick: () -> Void = {}
    var showExtraButton: Bool = false
    var extraBadgeCount: Int = 0

    var showRightIcons: Bool = true

    var body: some View {
        HStack {
            Button(action: onLeftClick) {
                Image(leftIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                    .foregroundStyle(theme.onBackground)
            }
            .accessibilityLabel(leftIconAccessibility)

            if let title = title {
                Text(title)
                    .foregroundStyle(theme.onSurface)
                    .font(typography.titleLarge)
                    .padding(.leading, Dimensions.Padding.XSPadding)
                    .accessibilityAddTraits(.isHeader)
            }

            Spacer()

            if showRightIcons {
                HStack(spacing: Dimensions.Padding.SPadding) {
                    if showExtraButton {
                        Button(action: onExtraButtonClick) {
                            ZStack(alignment: .topTrailing) {
                                Image(extraButtonIcon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                                    .foregroundStyle(theme.background)
                                if extraBadgeCount > 0 {
                                    Text(verbatim: "\(extraBadgeCount)")
                                        .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                                        .foregroundStyle(theme.background)
                                        .padding(Dimensions.Padding.XXSPadding)
                                        .background(Circle().fill(theme.onError))
                                        .offset(x: 10, y: -10)
                                }
                            }
                        }
                        .accessibilityLabel(extraButtonIconAccessibility)
                    }

                    if let onRightPrimaryClick = onRightPrimaryClick {
                        Button(action: onRightPrimaryClick) {
                            Image(rightPrimaryIcon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                                .foregroundStyle(theme.onBackground)
                        }
                        .accessibilityLabel(rightPrimaryIconAccessibility)
                    }

                    Button(action: onRightSecondaryClick) {
                        Image(rightSecondaryIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                            .foregroundStyle(theme.onBackground)
                    }
                    .accessibilityLabel(rightSecondaryIconAccessibility)
                }
            }
        }
        .padding(Dimensions.Padding.SPadding)
        .background(theme.surface)
    }
}
