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
import FactoryKit
import CommonsLib
import UtilsLib
import ConfigLibMocks
import CommonsLibMocks

@testable import ConfigLib

struct ConfigurationViewModelTests {

    let mockFileManager: FileManagerProtocolMock!
    let mockRepository: ConfigurationRepositoryProtocolMock!
    let viewModel: ConfigurationViewModel!
    let mockConfigProvider: ConfigurationProvider!

    init() async throws {
        mockFileManager = FileManagerProtocolMock()
        mockRepository = ConfigurationRepositoryProtocolMock()
        viewModel = await ConfigurationViewModel(repository: mockRepository, fileManager: mockFileManager)
        mockConfigProvider = try TestConfigurationProvider.mockConfigurationProvider()
    }

    @Test
    func fetchConfiguration_successUpdatingConfigurationWhenNoLastUpdateTime() async throws {

        mockRepository.getCentralConfigurationUpdatesHandler = { _, _, _ in
            return mockAsyncStream(configProvider: mockConfigProvider)
        }

        await viewModel.fetchConfiguration(lastUpdate: 0, proxyInfo: ProxyInfo(), userAgent: "TestUserAgent")

        let configuration = await viewModel.configuration

        #expect(mockConfigProvider.metaInf.url == configuration?.metaInf.url)
    }

    @Test
    func fetchConfiguration_successUpdatingConfigurationWhenBeforeLastUpdateTime() async throws {
        let configProvider = try TestConfigurationProvider.mockConfigurationProvider(configurationUpdateDate: nil)

        mockRepository.getCentralConfigurationUpdatesHandler = { _, _, _ in
            return mockAsyncStream(configProvider: configProvider)
        }

        await viewModel.fetchConfiguration(lastUpdate: -1, proxyInfo: ProxyInfo(), userAgent: "TestUserAgent")

        let configuration = await viewModel.configuration

        #expect(mockConfigProvider.metaInf.url == configuration?.metaInf.url)
    }

    @Test
    func fetchConfiguration_doesNotUpdateWhenCentralConfigurationUpdatesReturnsNil() async throws {

        mockRepository.getConfigurationUpdatesHandler = {
            return nil
        }

        mockRepository.getCentralConfigurationUpdatesHandler = { _, _, _ in
            return nil
        }

        let currentConf = await viewModel.getConfiguration()

        await viewModel.fetchConfiguration(lastUpdate: 0, proxyInfo: ProxyInfo(), userAgent: "TestUserAgent")

        let unchangedConf = await viewModel.getConfiguration()

        #expect(currentConf?.metaInf.serial == unchangedConf?.metaInf.serial)

        #expect(mockRepository.getCentralConfigurationUpdatesCallCount == 1)
    }

    @Test
    func fetchConfiguration_doesNotUpdateConfigurationWhenLastUpdateIsNewer() async throws {

        mockRepository.getCentralConfigurationUpdatesHandler = { _, _, _ in
            return mockAsyncStream(configProvider: mockConfigProvider)
        }

        await viewModel
            .fetchConfiguration(
                lastUpdate: Date().timeIntervalSince1970,
                proxyInfo: ProxyInfo(),
                userAgent: "TestUserAgent"
            )

        await #expect(viewModel.configuration == nil)
    }

    @Test
    func getConfiguration_noUpdatesReturnedWhenConfigurationUpdateNil() async throws {

        mockRepository.getCentralConfigurationUpdatesHandler = { _, _, _ in
            return nil
        }

        let result = await viewModel.getConfiguration()

        #expect(result == nil)
        #expect(mockRepository.getConfigurationUpdatesCallCount == 1)
    }

    @Test
    func getConfiguration_successReturningConfiguration() async throws {

        mockRepository.getConfigurationUpdatesHandler = {
            return mockAsyncStream(configProvider: mockConfigProvider)
        }

        let result = await viewModel.getConfiguration()

        #expect(mockConfigProvider.metaInf.url == result?.metaInf.url)
    }

    @Test
    func getConfiguration_noUpdatesWhenConfigurationNotFound() async throws {
        let asyncStream: AsyncThrowingStream<ConfigurationProvider?, Error> = AsyncThrowingStream { continuation in
            continuation.finish(throwing: ConfigurationLoaderError.configurationNotFound)
        }

        mockRepository.getCentralConfigurationUpdatesHandler = { _, _, _ in
            return asyncStream
        }

        let result = await viewModel.getConfiguration()

        #expect(result == nil)
        #expect(mockRepository.getConfigurationUpdatesCallCount == 1)
    }

    @Test
    func getConfiguration_returnNilWhenStreamYieldsNil() async {
        let asyncStream: AsyncThrowingStream<ConfigurationProvider?, Error> = AsyncThrowingStream { continuation in
            continuation.yield(nil)
            continuation.finish()
        }

        mockRepository.getCentralConfigurationUpdatesHandler = { _, _, _ in
            return asyncStream
        }

        let fetchedConfig = await viewModel.getConfiguration()

        #expect(fetchedConfig == nil)
    }

    @Test
    func getConfiguration_returnNilWhenStreamEmitsNothing() async {
        let asyncStream: AsyncThrowingStream<ConfigurationProvider?, Error> = AsyncThrowingStream { continuation in
            continuation.finish()
        }

        mockRepository.getCentralConfigurationUpdatesHandler = { _, _, _ in
            return asyncStream
        }

        let fetchedConfig = await viewModel.getConfiguration()

        #expect(fetchedConfig == nil)
    }

    private func mockAsyncStream(
        configProvider: ConfigurationProvider
    ) -> AsyncThrowingStream<
        ConfigurationProvider?,
        Error
    > {
        return AsyncThrowingStream { continuation in
            continuation.yield(configProvider)
            continuation.finish()
        }
    }
}
