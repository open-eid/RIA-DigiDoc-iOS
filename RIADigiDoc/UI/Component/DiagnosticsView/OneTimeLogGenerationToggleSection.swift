/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
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

struct OneTimeLogGenerationToggleSection: View {
    @AppTheme private var theme
    @AppTypography private var typography

    @Binding var enableOneTimeLogGeneration: Bool

    @EnvironmentObject private var languageSettings: LanguageSettings

    var body: some View {
        HStack {
            Text(languageSettings.localized("Main diagnostics logging switch"))
                .foregroundStyle(theme.onSurface)
                .font(typography.bodyLarge)
            Spacer()
            Toggle(
                isOn: $enableOneTimeLogGeneration,
                label: {}
            )
            .toggleStyle(SwitchToggleStyle(tint: theme.outline))
            .labelsHidden()
        }
        .padding(.vertical, Dimensions.Padding.SPadding)
    }
}

// MARK: - Preview
#Preview {
    OneTimeLogGenerationToggleSection(enableOneTimeLogGeneration: .constant(false))
        .environmentObject(Container.shared.languageSettings())
        .environmentObject(Container.shared.themeSettings())
}
