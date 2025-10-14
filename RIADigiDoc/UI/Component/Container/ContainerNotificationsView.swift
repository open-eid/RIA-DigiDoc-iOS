import SwiftUI
import FactoryKit

struct ContainerNotificationsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var languageSettings: LanguageSettings

    @AppTheme private var theme
    @AppTypography private var typography

    private let isSettingsMenuBottomSheetVisible = false
    let notifications: [ContainerNotificationType]

    var body: some View {
        TopBarContainer(
            title: languageSettings.localized("Container notifications"),
            onLeftClick: {
                dismiss()
            },
            content: {
                ScrollView {
                    VStack(alignment: .leading) {
                        Divider()

                        ForEach(notifications.indices, id: \.self) { index in
                            HStack(alignment: .center) {
                                Image("ic_m3_notifications_48pt_wght400")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(theme.onBackground)
                                    .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                                    .padding(Dimensions.Padding.XSPadding)
                                    .accessibilityHidden(true)

                                Text(verbatim: message(for: notifications[index]))
                                    .font(typography.bodyMedium)
                                    .foregroundStyle(theme.onSurfaceVariant)
                            }
                            .padding(.horizontal, Dimensions.Padding.XXSPadding)

                            Divider()
                        }
                    }
                    .padding(.vertical, Dimensions.Padding.SPadding)
                }
            }
        )
    }

    private func message(for notification: ContainerNotificationType) -> String {
        switch notification {
        case .xadesFile:
            return "XAdES" // TODO: Add XAdES message
        case .cadesFile:
            return languageSettings.localized("Cades message")
        case .unknownSignatures(let count):
            return languageSettings.localized("Unknown signature", [count])
        case .invalidSignatures(let count):
            return languageSettings.localized("Invalid signature \(count)")
        case .emptyFile:
            return languageSettings.localized("Empty file in container")
        case .unsupportedContainer:
            return languageSettings.localized("Unsupported container")
        }
    }
}

#Preview {
    ContainerNotificationsView(
        notifications: [
            .emptyFile,
            .unknownSignatures(count: 1)
        ]
    )
    .environmentObject(Container.shared.languageSettings())
    .environmentObject(Container.shared.themeSettings())
}
