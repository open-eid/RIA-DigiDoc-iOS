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
import ConfigLib

struct DiagnosticsSections: View {
    @Environment(LanguageSettings.self) private var languageSettings

    var versionSectionContent: String
    var osSectionContent: (key: String, content: String)
    var libdigidocVersion: String
    var urlSectionContent: [(key: String, content: String)]
    var cdoc2SectionContent: [String]
    var tslSectionContent: [String]
    var centralConfigurationSectionContent: [(key: String, content: String)]

    var body: some View {
        VStack {
            DiagnosticsSingleSection(
                title: languageSettings.localized("Main diagnostics application version title"),
                content: versionSectionContent,
                identifier: "applicationVersion"
            )

            DiagnosticsSingleSection(
                title: languageSettings.localized(osSectionContent.key),
                content: osSectionContent.content,
                identifier: "osVersion",
            )

            DiagnosticsSingleSection(
                title: languageSettings.localized("Main diagnostics libraries title"),
                content: libdigidocVersion,
                identifier: "library"
            )

            DiagnosticsSingleSection(
                title: languageSettings.localized("Main diagnostics urls title"),
                contentLines: urlSectionContent
                    .map { "\($0.key): \(languageSettings.localized($0.content))" },
                identifier: "url",
                showDivider: false,
            )

            DiagnosticsSingleSection(
                title: languageSettings.localized("Main diagnostics cdoc2 title"),
                contentLines: cdoc2SectionContent,
                identifier: "cdoc2",
            )

            DiagnosticsSingleSection(
                title: languageSettings.localized("Main diagnostics tsl cache title"),
                contentLines: tslSectionContent,
                identifier: "tslCache",
            )

            DiagnosticsSingleSection(
                title: languageSettings.localized("Main diagnostics central configuration title"),
                contentLines: centralConfigurationSectionContent
                    .map { "\(languageSettings.localized($0.key)): \($0.content)"
                    },
                identifier: "centralConfiguration"
            )
        }
    }
}

// MARK: - Preview
#Preview {
    DiagnosticsSections(
        versionSectionContent: "",
        osSectionContent: (key: "", content: ""),
        libdigidocVersion: "",
        urlSectionContent: [(key: "", content: "")],
        cdoc2SectionContent: [""],
        tslSectionContent: [""],
        centralConfigurationSectionContent: [(key: "", content: "")]
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
