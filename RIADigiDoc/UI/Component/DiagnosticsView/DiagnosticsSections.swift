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

import FactoryKit
import SwiftUI

struct DiagnosticsSections: View {
    @EnvironmentObject private var languageSettings: LanguageSettings

    @EnvironmentObject private var viewModel: DiagnosticsViewModel

    var body: some View {
        if viewModel.configuration != nil {
            DiagnosticsSingleSection(
                title: languageSettings.localized("Main diagnostics application version title"),
                content: viewModel.versionSectionContent
            )

            DiagnosticsSingleSection(
                title: languageSettings.localized(viewModel.osSectionContent.key),
                content: viewModel.osSectionContent.content,
            )

            DiagnosticsSingleSection(
                title: languageSettings.localized("Main diagnostics libraries title"),
                content: viewModel.libdigidocVersion
            )

            DiagnosticsSingleSection(
                title: languageSettings.localized("Main diagnostics urls title"),
                contentLines: viewModel.urlSectionContent,
                showDivider: false,
            )

            DiagnosticsSingleSection(
                title: languageSettings.localized("Main diagnostics cdoc2 title"),
                contentLines: viewModel.cdoc2SectionContent,
            )

            DiagnosticsSingleSection(
                title: languageSettings.localized("Main diagnostics tsl cache title"),
                contentLines: viewModel.tslSectionContent,
            )

            DiagnosticsSingleSection(
                title: languageSettings.localized("Main diagnostics central configuration title"),
                contentLines: viewModel.centralConfigurationSectionContent
                    .map { "\(languageSettings.localized($0.key)): \($0.content)"
                }
            )
        }
    }
}

// MARK: - Preview
#Preview {
    DiagnosticsSections()
        .environmentObject(Container.shared.languageSettings())
        .environmentObject(Container.shared.themeSettings())
}
