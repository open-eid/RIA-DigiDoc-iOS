import SwiftUI

struct Typography {
    let displayLarge: Font
    let displayMedium: Font
    let displaySmall: Font

    let headlineLarge: Font
    let headlineMedium: Font
    let headlineSmall: Font

    let titleLarge: Font
    let titleMedium: Font
    let titleSmall: Font

    let bodyLarge: Font
    let bodyMedium: Font
    let bodySmall: Font

    let labelLarge: Font
    let labelMedium: Font
    let labelSmall: Font
}

extension Typography {
    static func current() -> Typography {
        Typography(
            displayLarge: FontTypography.font(for: .displayLarge),
            displayMedium: FontTypography.font(for: .displayMedium),
            displaySmall: FontTypography.font(for: .displaySmall),

            headlineLarge: FontTypography.font(for: .headlineLarge),
            headlineMedium: FontTypography.font(for: .headlineMedium),
            headlineSmall: FontTypography.font(for: .headlineSmall),

            titleLarge: FontTypography.font(for: .titleLarge),
            titleMedium: FontTypography.font(for: .titleMedium),
            titleSmall: FontTypography.font(for: .titleSmall),

            bodyLarge: FontTypography.font(for: .bodyLarge),
            bodyMedium: FontTypography.font(for: .bodyMedium),
            bodySmall: FontTypography.font(for: .bodySmall),

            labelLarge: FontTypography.font(for: .labelLarge),
            labelMedium: FontTypography.font(for: .labelMedium),
            labelSmall: FontTypography.font(for: .labelSmall)
        )
    }
}

private struct TypographyKey: EnvironmentKey {
    static let defaultValue = Typography.current()
}

extension EnvironmentValues {
    var typography: Typography {
        get { self[TypographyKey.self] }
        set { self[TypographyKey.self] = newValue }
    }
}
