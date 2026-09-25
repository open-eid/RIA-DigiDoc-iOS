// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
    var settingsSectionContent: [String]
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
                title: languageSettings.localized("Main diagnostics settings title"),
                contentLines: settingsSectionContent,
                identifier: "settings",
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
        settingsSectionContent: [""],
        tslSectionContent: [""],
        centralConfigurationSectionContent: [(key: "", content: "")]
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
