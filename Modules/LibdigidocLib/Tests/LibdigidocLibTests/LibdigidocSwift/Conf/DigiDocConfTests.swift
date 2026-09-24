// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import Testing
import LibdigidocLibObjC
import ConfigLib
import UtilsLib
import CommonsLib
import ConfigLibMocks
import CommonsLibMocks

@testable import LibdigidocLibSwift

final class DigiDocConfTests {

    private let mockConfigurationRepository: ConfigurationRepositoryProtocolMock
    private let mockConfigurationLoader: ConfigurationLoaderProtocolMock
    private let configurationProvider: ConfigurationProvider

    init() async throws {
        mockConfigurationRepository = ConfigurationRepositoryProtocolMock()
        mockConfigurationLoader = ConfigurationLoaderProtocolMock()
        configurationProvider = try TestConfigurationProviderUtil.getConfigurationProvider()

        try DigiDocConf.observeConfigurationUpdates(configurationRepository: mockConfigurationRepository)

        try await mockConfigurationLoader.initConfiguration(
            configDir: URL(fileURLWithPath: "/mock/path"),
            proxyInfo: ProxyInfo(),
            userAgent: "TestUserAgent"
        )
    }

    @Test
    func initDigiDoc_successAndReInitialization() async {
        do {
            try await DigiDocConf.initDigiDoc(
                configuration: configurationProvider,
                userAgent: "TestUserAgent"
            )

            #expect(true)

            try await DigiDocConf.initDigiDoc(
                configuration: configurationProvider,
                userAgent: "TestUserAgent"
            )

            Issue.record("Expected DigiDocError.alreadyInitialized to be thrown")
            return
        } catch let error as DigiDocError {
            switch error {
            case .alreadyInitialized:
                #expect(true)
            default:
                Issue.record("Unexpected error: \(error.localizedDescription)")
                return
            }
        } catch {
            Issue.record("Initialization failed with error: \(error.localizedDescription)")
            return
        }
    }
}
