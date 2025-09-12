import FactoryKit
import SwiftUI

struct RadioButtonChooserView<T: Equatable & Identifiable>: View where T: Hashable {
    @AppTheme private var theme
    @EnvironmentObject private var languageSettings: LanguageSettings
    @Environment(\.dismiss) private var dismiss

    let title: String
    let options: [T]
    let isSelected: (T) -> Bool
    let titleKey: (T) -> String
    let onSelect: (T) -> Void
    let accessibilityLabel: (T, Bool) -> String

    var body: some View {
        TopBarContainer(
            title: title,
            onLeftClick: {
                dismiss()
            },
            content: {
                VStack(
                    spacing: Dimensions.Padding.ZeroPadding,
                    content: {
                        ForEach(options, id: \.id) { option in
                            RadioButtonRow<T>(
                                title: languageSettings.localized(titleKey(option)),
                                isSelected: isSelected(option),
                                onTap: { onSelect(option) },
                                accessibilityLabel: accessibilityLabel(option, isSelected(option))
                            )
                            Divider()
                        }
                        Spacer()
                    }
                )
            }
        )
        .background(theme.surface)
    }
}
