import Foundation
import Testing
import UtilsLib
import ConfigLibMocks
import CommonsLibMocks

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
    func getConfiguration_success() async {
        let expectedConfiguration = TestConfigurationProvider.mockConfigurationProvider()

        mockConfigurationLoader.getConfigurationHandler = { expectedConfiguration }

        let configuration = await repository.getConfiguration()

        #expect(expectedConfiguration.sivaUrl == configuration?.sivaUrl)
        #expect(mockConfigurationLoader.getConfigurationCallCount == 1)
    }

    @Test
    func getConfigurationUpdates_success() async throws {
        let stream = AsyncThrowingStream<ConfigurationProvider?, Error> { continuation in
            continuation.yield(TestConfigurationProvider.mockConfigurationProvider())
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
        let expectedConfiguration = TestConfigurationProvider.mockConfigurationProvider()
        let mockCacheDir = URL(fileURLWithPath: "/mock/cache/dir")

        mockConfigurationLoader.loadCentralConfigurationHandler = { _ in }
        mockConfigurationLoader.getConfigurationHandler = { expectedConfiguration }

        let configuration = try await repository.getCentralConfiguration(cacheDir: mockCacheDir)

        #expect(expectedConfiguration.tslUrl == configuration?.tslUrl)
        #expect(mockConfigurationLoader.loadCentralConfigurationArgValues.first == mockCacheDir)
        #expect(mockConfigurationLoader.getConfigurationCallCount == 1)
    }

    @Test
    func getCentralConfiguration_returnConfigurationThatUsesDefaultConfiguration() async throws {
        let expectedConfiguration = TestConfigurationProvider.mockConfigurationProvider()

        mockConfigurationLoader.loadCentralConfigurationHandler = { _ in }
        mockConfigurationLoader.getConfigurationHandler = { expectedConfiguration }

        let configuration = try await repository.getCentralConfiguration(cacheDir: nil)

        let isCorrectDirectory = try mockConfigurationLoader.loadCentralConfigurationArgValues.first == Directories
            .getConfigDirectory(fileManager: mockFileManager)

        #expect(expectedConfiguration.tslUrl == configuration?.tslUrl)
        #expect(isCorrectDirectory)
        #expect(mockConfigurationLoader.getConfigurationCallCount == 1)
    }

    @Test
    func getCentralConfigurationUpdates_success() async throws {
        let mockCacheDir = URL(fileURLWithPath: "/mock/cache/dir")
        let stream = AsyncThrowingStream<ConfigurationProvider?, Error> { continuation in
            continuation
                .yield(TestConfigurationProvider.mockConfigurationProvider())
            continuation.finish()
        }

        mockConfigurationLoader.loadCentralConfigurationHandler = { _ in }
        mockConfigurationLoader.getConfigurationUpdatesHandler = { _ in stream }

        let resultStream = try await repository.getCentralConfigurationUpdates(cacheDir: mockCacheDir)

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
            mockConfigurationLoader.loadCentralConfigurationArgValues.first == mockCacheDir
        )
        #expect(mockConfigurationLoader.getConfigurationUpdatesCallCount == 1)
    }

    @Test
    func getCentralConfigurationUpdates_returnConfigurationThatUsesDefaultConfiguration() async throws {
        let stream = AsyncThrowingStream<ConfigurationProvider?, Error> { continuation in
            continuation.yield(TestConfigurationProvider.mockConfigurationProvider())
            continuation.finish()
        }

        mockConfigurationLoader.loadCentralConfigurationHandler = { _ in }
        mockConfigurationLoader.getConfigurationUpdatesHandler = { _ in stream }

        let resultStream = try await repository.getCentralConfigurationUpdates(cacheDir: nil)

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

        let isCorrectDirectory = try mockConfigurationLoader.loadCentralConfigurationArgValues.first == Directories
            .getConfigDirectory(fileManager: mockFileManager)
        #expect(isCorrectDirectory)
        #expect(mockConfigurationLoader.getConfigurationUpdatesCallCount == 1)
    }

    @Test
    func observeConfigurationUpdates_handleErrorWhenStreamReturnsError() async throws {
        let stream = AsyncThrowingStream<ConfigurationProvider?, Error> { continuation in
            continuation.yield(TestConfigurationProvider.mockConfigurationProvider())
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
