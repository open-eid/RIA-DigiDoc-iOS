// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import Testing

struct LanguageSettingsTests {
    private let mockDataStore: DataStoreProtocolMock

    private let languageSettings: LanguageSettingsProtocol

    init() async {
        mockDataStore = DataStoreProtocolMock()

        languageSettings = await LanguageSettings(dataStore: mockDataStore)
    }

    @Test
    func getSelectedLanguage_success() async throws {
        let allowedLanguageCodes: [String] = ["en", "et"]
        let selectedLanguage: String = await languageSettings.getSelectedLanguage()
        #expect(allowedLanguageCodes.contains(selectedLanguage))
    }

    @Test
    func localized_doesNotTreatAnUnknownKeyAsAFormatString() async throws {
        let key = "Document with same file name report %@ %d.pdf already exists"

        let result = await languageSettings.localized(key, ["ignored"])

        #expect(result == key)
    }

    @Test
    func localized_stillFormatsAKnownKey() async throws {
        let result = await languageSettings.localized("Could not add files", ["3"])

        #expect(result != "Could not add files")
        #expect(result.contains("3"))
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
