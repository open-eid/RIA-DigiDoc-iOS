/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

import SwiftUI
import FactoryKit
import IdCardLib
import CommonsLib

struct IdCardLoadingView: View {
    @Environment(LanguageSettings.self) private var languageSettings

    @AppTheme private var theme
    @AppTypography private var typography

    private let actionType: ActionType

    private var actionMessage: String {
        switch actionType {
        case .signing:
            return languageSettings.localized("Signing in progress")
        case .decrypt:
            return languageSettings.localized("Decrypting in progress")
        default:
            break
        }

        return ""
    }

    init(
        actionType: ActionType
    ) {
        self.actionType = actionType
    }

    var body: some View {
        VStack(alignment: .center, spacing: Dimensions.Padding.MPadding) {
            LoadingView()
                .padding(.top, Dimensions.Padding.MPadding)

            Text(verbatim: actionMessage)
                .font(typography.titleLarge)
                .foregroundStyle(theme.onSurface)
        }
    }
}

#Preview {
    IdCardLoadingView(
        actionType: .signing
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
