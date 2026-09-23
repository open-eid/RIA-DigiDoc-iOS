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

import Foundation
import Testing

struct LanguageSettingsTests {
    private let mockDataStore: DataStoreProtocolMock

    private let languageSettings: LanguageSettingsProtocol

    init() async {
        mockDataStore = DataStoreProtocolMock()

        languageSettings = await LanguageSettings(dataStore: mockDataStore)
    }

    // MARK: - Tests

    @Test
    func getSelectedLanguage_success() async throws {
        let allowedLanguageCodes: [String] = ["en", "et"]
        let selectedLanguage: String = await languageSettings.getSelectedLanguage()
        #expect(allowedLanguageCodes.contains(selectedLanguage))
    }

    @Test
    func setSelectedLanguage_success() async throws {
        let testLanguageCode: String = "et"

        mockDataStore.getSelectedLanguageHandler = {
            return testLanguageCode
        }

        await languageSettings.setSelectedLanguage(newLanguageCode: testLanguageCode)

        #expect(await languageSettings.getSelectedLanguage() == testLanguageCode)
        #expect(mockDataStore.setSelectedLanguageCallCount == 1)
    }

    @Test(arguments: ["en", "et"])
    func localized_resolvesEveryInfoLinkKeyToWebUrl(languageCode: String) async throws {
        let infoLinkKeys = [
            "ID card courier activate URL",
            "Invalid signing access rights url",
            "Main accessibility more info url",
            "Main home menu help url",
            "OCSP response not in valid time slot url",
            "PIN1 locked URL",
            "PIN2 locked URL",
            "PUK blocked Thales URL",
            "PUK blocked URL",
            "Siva message url",
            "Too many requests url"
        ]

        mockDataStore.getSelectedLanguageHandler = { languageCode }
        await languageSettings.setSelectedLanguage(newLanguageCode: languageCode)

        for key in infoLinkKeys {
            let localizedUrl = await languageSettings.localized(key)
            let url = try #require(URL(string: localizedUrl), "'\(key)' is not a URL in \(languageCode)")
            #expect(url.scheme == "https", "'\(key)' is not an https URL in \(languageCode)")
        }
    }
}
