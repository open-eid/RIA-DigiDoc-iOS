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
        mockConfigProvider = TestConfigurationProvider.mockConfigurationProvider()
    }

    @Test
    func fetchConfiguration_successUpdatingConfigurationWhenNoLastUpdateTime() async throws {

        mockRepository.getCentralConfigurationUpdatesHandler = { _ in
            return mockAsyncStream(configProvider: mockConfigProvider)
        }

        await viewModel.fetchConfiguration(lastUpdate: 0)

        let configuration = await viewModel.configuration

        #expect(mockConfigProvider.metaInf.url == configuration?.metaInf.url)
    }

    @Test
    func fetchConfiguration_successUpdatingConfigurationWhenBeforeLastUpdateTime() async throws {
        let configProvider = TestConfigurationProvider.mockConfigurationProvider(configurationUpdateDate: nil)

        mockRepository.getCentralConfigurationUpdatesHandler = { _ in
            return mockAsyncStream(configProvider: configProvider)
        }

        await viewModel.fetchConfiguration(lastUpdate: -1)

        let configuration = await viewModel.configuration

        #expect(mockConfigProvider.metaInf.url == configuration?.metaInf.url)
    }

    @Test
    func fetchConfiguration_doesNotUpdateWhenCentralConfigurationUpdatesReturnsNil() async throws {

        mockRepository.getConfigurationUpdatesHandler = {
            return nil
        }

        mockRepository.getCentralConfigurationUpdatesHandler = { _ in
            return nil
        }

        let currentConf = await viewModel.getConfiguration()

        await viewModel.fetchConfiguration(lastUpdate: 0)

        let unchangedConf = await viewModel.getConfiguration()

        #expect(currentConf?.metaInf.serial == unchangedConf?.metaInf.serial)

        #expect(mockRepository.getCentralConfigurationUpdatesCallCount == 1)
    }

    @Test
    func fetchConfiguration_doesNotUpdateConfigurationWhenLastUpdateIsNewer() async throws {

        mockRepository.getCentralConfigurationUpdatesHandler = { _ in
            return mockAsyncStream(configProvider: mockConfigProvider)
        }

        await viewModel.fetchConfiguration(lastUpdate: Date().timeIntervalSince1970)

        await #expect(viewModel.configuration == nil)
    }

    @Test
    func getConfiguration_noUpdatesReturnedWhenConfigurationUpdateNil() async throws {

        mockRepository.getCentralConfigurationUpdatesHandler = { _ in
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

        mockRepository.getCentralConfigurationUpdatesHandler = { _ in
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

        mockRepository.getCentralConfigurationUpdatesHandler = { _ in
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

        mockRepository.getCentralConfigurationUpdatesHandler = { _ in
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
