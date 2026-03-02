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
import LibdigidocLibSwift
import CommonsLib
import IdCardLib
import UtilsLib

struct WebEidView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageSettings.self) private var languageSettings
    @Environment(NavigationPathManager.self) private var pathManager

    @AppTheme private var theme
    @AppTypography private var typography

    @State private var viewModel: WebEidViewModel

    private var webEidUrl: URL

    init(
        webEidUrl: URL,
    ) {
        _viewModel = State(wrappedValue: Container.shared.webEidViewModel())
        self.webEidUrl = webEidUrl
    }

    var body: some View {
        ZStack {
            TopBarContainer(
                title: languageSettings.localized("Main home web eid title"),
                onLeftClick: {
                    // TODO: implement me

                    dismiss()
                },
                content: {
                    ScrollView {
                        VStack {
                            // TODO: implement me
                        }
                        .padding(.horizontal, Dimensions.Padding.SPadding)
                    }
                }
            )
        }
        .onAppear {
            // TODO: implement me
        }
    }
}

#Preview {
    WebEidView(
        webEidUrl: URL(fileURLWithPath: "")
    )
}
