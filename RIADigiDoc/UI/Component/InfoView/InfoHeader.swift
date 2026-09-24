// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit

struct InfoHeader: View {
    var body: some View {
        HStack(spacing: Dimensions.Padding.MPadding) {
            InfoHeaderLogoComponent()
            InfoHeaderTextComponent()
        }
        .padding(.vertical, Dimensions.Padding.XSPadding)
        .padding(.horizontal, Dimensions.Padding.SPadding)
    }
}

// MARK: - Preview
#Preview {
    InfoHeader()
        .environment(Container.shared.languageSettings())
        .environment(Container.shared.themeSettings())
}
