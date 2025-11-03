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
            cacheDir: URL(fileURLWithPath: "/mock/path"),
            proxyInfo: ProxyInfo()
        )
    }

    @Test
    func initDigiDoc_successAndReInitialization() async {
        do {
            try await DigiDocConf.initDigiDoc(configuration: configurationProvider)
            #expect(true)

            try await DigiDocConf.initDigiDoc(configuration: configurationProvider)

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
