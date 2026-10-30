// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import ConfigLib
import ConfigLibMocks
import Foundation
import Testing

@MainActor
final class AppVersionUtilTests {
    private let appVersionUtil: AppVersionUtil

    private let mockConfigurationLoader: ConfigurationLoaderProtocolMock!

    init() {
        mockConfigurationLoader = ConfigurationLoaderProtocolMock()
        appVersionUtil = AppVersionUtil(configurationLoader: mockConfigurationLoader)
    }

    private func configuration(unsupportedAppVersion: String?) throws -> ConfigurationProvider {
        try TestConfigurationProvider.mockConfigurationProvider(unsupportedAppVersion: unsupportedAppVersion)
    }

    @Test
    func isAppVersionUnsupported_returnFalseWhenConfigurationIsMissing() async {
        mockConfigurationLoader.getConfigurationHandler = { nil }

        #expect(await !appVersionUtil.isAppVersionUnsupported())
    }

    @Test
    func isAppVersionUnsupported_returnFalseWhenUnsupportedVersionIsNotSet() async throws {
        let provider = try configuration(unsupportedAppVersion: nil)
        mockConfigurationLoader.getConfigurationHandler = { provider }

        #expect(await !appVersionUtil.isAppVersionUnsupported())
    }

    @Test
    func isAppVersionUnsupported_returnTrueWhenAppVersionIsLower() async throws {
        let provider = try configuration(unsupportedAppVersion: "999.0.0")
        mockConfigurationLoader.getConfigurationHandler = { provider }

        #expect(await appVersionUtil.isAppVersionUnsupported())
    }

    @Test
    func isAppVersionUnsupported_returnFalseWhenAppVersionIsHigher() async throws {
        let provider = try configuration(unsupportedAppVersion: "0.0.1")
        mockConfigurationLoader.getConfigurationHandler = { provider }

        #expect(await !appVersionUtil.isAppVersionUnsupported())
    }

    @Test
    func isAppVersionUnsupported_reevaluatesConfigurationOnEveryCall() async throws {
        let supported = try configuration(unsupportedAppVersion: nil)
        mockConfigurationLoader.getConfigurationHandler = { supported }

        #expect(await !appVersionUtil.isAppVersionUnsupported())

        let unsupported = try configuration(unsupportedAppVersion: "999.0.0")
        mockConfigurationLoader.getConfigurationHandler = { unsupported }

        #expect(await appVersionUtil.isAppVersionUnsupported())
        #expect(mockConfigurationLoader.getConfigurationCallCount == 2)
    }
}
