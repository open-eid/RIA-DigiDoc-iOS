import Foundation

struct BottomSheetButton: Identifiable {
    let id = UUID()
    let showButton: Bool
    let icon: String
    let title: String
    let accessibilityLabel: String
    let showExtraIcon: Bool
    let extraIcon: String
    let onClick: () -> Void

    init(showButton: Bool = true,
         icon: String,
         title: String,
         accessibilityLabel: String,
         showExtraIcon: Bool = false,
         extraIcon: String = "ic_m3_arrow_right_48pt_wght400",
         onClick: @escaping () -> Void) {
        self.showButton = showButton
        self.icon = icon
        self.title = title
        self.accessibilityLabel = accessibilityLabel
        self.showExtraIcon = showExtraIcon
        self.extraIcon = extraIcon
        self.onClick = onClick
    }
}
