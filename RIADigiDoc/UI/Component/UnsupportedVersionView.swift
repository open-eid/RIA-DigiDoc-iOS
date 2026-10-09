// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit
import UtilsLib

struct UnsupportedVersionView: View, Loggable {
    @AppTheme private var theme
    @AppTypography private var typography
    @Environment(LanguageSettings.self) private var languageSettings

    private var message: AttributedString {
        let text = languageSettings.localized("App version unsupported message")
        do {
            return try AttributedString(markdown: text)
        } catch {
            UnsupportedVersionView.logger().error(
                "Unable to parse unsupported version message: \(String(reflecting: error), privacy: .public)"
            )
            return AttributedString(text)
        }
    }

    var body: some View {
        ZStack {
            theme.surface.ignoresSafeArea()

            ScrollView {
                if let url = message.runs.compactMap(\.link).first {
                    Link(destination: url) {
                        messageText
                    }
                } else {
                    messageText
                }
            }
            .defaultScrollAnchor(.center, for: .alignment)
        }
    }

    private var messageText: some View {
        var styledMessage = message
        for run in styledMessage.runs where run.link != nil {
            styledMessage[run.range].foregroundColor = theme.primary
            styledMessage[run.range].underlineStyle = .single
            styledMessage[run.range].link = nil
        }

        return Text(styledMessage)
            .foregroundStyle(theme.onSurface)
            .font(typography.bodyLarge)
            .multilineTextAlignment(.center)
            .padding()
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    UnsupportedVersionView()
        .environment(Container.shared.languageSettings())
        .environment(Container.shared.themeSettings())
}
