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

import CommonsLib
import CommonsLibMocks
import ConfigLibMocks
import Foundation
import Testing
import UtilsLib

@testable import ConfigLib

struct ConfigurationRepositoryTests {
    private let mockFileManager: FileManagerProtocolMock!
    private let mockConfigurationLoader: ConfigurationLoaderProtocolMock!
    private let repository: ConfigurationRepository!

    init() async throws {
        mockFileManager = FileManagerProtocolMock()
        mockConfigurationLoader = ConfigurationLoaderProtocolMock()
        repository = ConfigurationRepository(
            configurationLoader: mockConfigurationLoader,
            fileManager: mockFileManager
        )
    }

    @Test
    func getConfiguration_success() async throws {
        let expectedConfiguration = try TestConfigurationProvider.mockConfigurationProvider()

        mockConfigurationLoader.getConfigurationHandler = { expectedConfiguration }

        let configuration = await repository.getConfiguration()

        #expect(expectedConfiguration.sivaUrl == configuration?.sivaUrl)
        #expect(mockConfigurationLoader.getConfigurationCallCount == 1)
    }

    @Test
    func getConfigurationUpdates_success() async throws {
        let mockConfigurationProvider = try TestConfigurationProvider.mockConfigurationProvider()
        let stream = AsyncThrowingStream<ConfigurationProvider?, Error> { continuation in
            continuation.yield(mockConfigurationProvider)
            continuation.finish()
        }

        mockConfigurationLoader.getConfigurationUpdatesHandler = { _ in stream }

        let resultStream = await repository.getConfigurationUpdates()

        #expect(resultStream != nil)

        guard let stream = resultStream else {
            Issue.record("Unable to get result stream")
            return
        }

        var receivedConfigurations = [ConfigurationProvider?]()
        for try await configuration in stream {
            receivedConfigurations.append(configuration)
        }
        #expect(1 == receivedConfigurations.count)
        #expect(mockConfigurationLoader.getConfigurationUpdatesCallCount == 1)
    }

    @Test
    func getCentralConfiguration_success() async throws {
        let expectedConfiguration = try TestConfigurationProvider.mockConfigurationProvider()
        let mockCacheDir = URL(fileURLWithPath: "/mock/cache/dir")

        mockConfigurationLoader.loadCentralConfigurationHandler = { _, _, _ in }
        mockConfigurationLoader.getConfigurationHandler = { expectedConfiguration }

        let configuration = try await repository.getCentralConfiguration(
            cacheDir: mockCacheDir,
            proxyInfo: ProxyInfo(),
            userAgent: "TestUserAgent"
        )

        #expect(expectedConfiguration.tslUrl == configuration?.tslUrl)
        #expect(mockConfigurationLoader.loadCentralConfigurationArgValues.first?.cacheDir == mockCacheDir)
        #expect(mockConfigurationLoader.getConfigurationCallCount == 1)
    }

    @Test
    func getCentralConfiguration_returnConfigurationThatUsesDefaultConfiguration() async throws {
        let expectedConfiguration = try TestConfigurationProvider.mockConfigurationProvider()

        mockConfigurationLoader.loadCentralConfigurationHandler = { _, _, _ in }
        mockConfigurationLoader.getConfigurationHandler = { expectedConfiguration }

        let configuration = try await repository.getCentralConfiguration(
            cacheDir: nil,
            proxyInfo: ProxyInfo(),
            userAgent: "TestUserAgent"
        )

        let isCorrectDirectory = try mockConfigurationLoader.loadCentralConfigurationArgValues.first?.cacheDir ==
        Directories.getConfigDirectory(fileManager: mockFileManager)

        #expect(expectedConfiguration.tslUrl == configuration?.tslUrl)
        #expect(isCorrectDirectory)
        #expect(mockConfigurationLoader.getConfigurationCallCount == 1)
    }

    @Test
    func getCentralConfigurationUpdates_success() async throws {
        let mockConfigurationProvider = try TestConfigurationProvider.mockConfigurationProvider()
        let mockCacheDir = URL(fileURLWithPath: "/mock/cache/dir")
        let stream = AsyncThrowingStream<ConfigurationProvider?, Error> { continuation in
            continuation.yield(mockConfigurationProvider)
            continuation.finish()
        }

        mockConfigurationLoader.loadCentralConfigurationHandler = { _, _, _ in }
        mockConfigurationLoader.getConfigurationUpdatesHandler = { _ in stream }

        let resultStream = try await repository.getCentralConfigurationUpdates(
            cacheDir: mockCacheDir,
            proxyInfo: ProxyInfo(),
            userAgent: "TestUserAgent"
        )

        #expect(resultStream != nil)

        guard let stream = resultStream else {
            Issue.record("Unable to get result stream")
            return
        }

        var receivedConfigurations = [ConfigurationProvider?]()
        for try await configuration in stream {
            receivedConfigurations.append(configuration)
        }
        #expect(1 == receivedConfigurations.count)
        #expect(
            mockConfigurationLoader.loadCentralConfigurationArgValues.first?.cacheDir == mockCacheDir
        )
        #expect(mockConfigurationLoader.getConfigurationUpdatesCallCount == 1)
    }

    @Test
    func getCentralConfigurationUpdates_returnConfigurationThatUsesDefaultConfiguration() async throws {
        let mockConfigurationProvider = try TestConfigurationProvider.mockConfigurationProvider()
        let stream = AsyncThrowingStream<ConfigurationProvider?, Error> { continuation in
            continuation.yield(mockConfigurationProvider)
            continuation.finish()
        }

        mockConfigurationLoader.loadCentralConfigurationHandler = { _, _, _ in }
        mockConfigurationLoader.getConfigurationUpdatesHandler = { _ in stream }

        let resultStream = try await repository.getCentralConfigurationUpdates(
            cacheDir: nil,
            proxyInfo: ProxyInfo(),
            userAgent: "TestUserAgent"
        )

        #expect(resultStream != nil)

        guard let stream = resultStream else {
            Issue.record("Unable to get result stream")
            return
        }

        var receivedConfigurations = [ConfigurationProvider?]()
        for try await configuration in stream {
            receivedConfigurations.append(configuration)
        }
        #expect(1 == receivedConfigurations.count)

        let isCorrectDirectory = try mockConfigurationLoader.loadCentralConfigurationArgValues.first?.cacheDir ==
        Directories.getConfigDirectory(fileManager: mockFileManager)
        #expect(isCorrectDirectory)
        #expect(mockConfigurationLoader.getConfigurationUpdatesCallCount == 1)
    }

    @Test
    func observeConfigurationUpdates_handleErrorWhenStreamReturnsError() async throws {
        let mockConfigurationProvider = try TestConfigurationProvider.mockConfigurationProvider()
        let stream = AsyncThrowingStream<ConfigurationProvider?, Error> { continuation in
            continuation.yield(mockConfigurationProvider)
            continuation.finish(throwing: NSError(domain: "TestError", code: 1))
        }

        mockConfigurationLoader.getConfigurationUpdatesHandler = { _ in stream }

        let observedStream = await repository.observeConfigurationUpdates()

        #expect(observedStream != nil)

        guard let stream = observedStream else {
            Issue.record("Unable to get observed stream")
            return
        }

        var receivedConfigurations = [ConfigurationProvider?]()
        do {
            for try await configuration in stream {
                receivedConfigurations.append(configuration)
            }
        } catch {
            #expect("TestError" == (error as NSError).domain)
        }
        #expect(1 == receivedConfigurations.count)
        #expect(mockConfigurationLoader.getConfigurationUpdatesCallCount == 1)
    }
}
