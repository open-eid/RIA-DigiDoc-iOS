import CommonsTestShared
import ConfigLib
import Foundation

public struct TestConfigurationSetup {
    public static func configureMocks(
        configurationRepository: ConfigurationRepositoryProtocolMock,
        configProvider: ConfigurationProvider?
    ) {
        configurationRepository.observeConfigurationUpdatesHandler = { [configProvider] in
            guard let mockConfig = configProvider else {
                return AsyncThrowingStream { continuation in
                    continuation.yield(nil)
                    continuation.finish(
                        throwing: DecodingError.valueNotFound(
                            Int.self,
                            DecodingError.Context(
                                codingPath: [],
                                debugDescription:
                                    "Expected a non-nil mockConfigProvider value"
                            )
                        )
                    )
                }
            }

            return mockAsyncStream(configProvider: mockConfig)
        }

        configurationRepository.getCentralConfigurationUpdatesHandler = { [configProvider] _ async throws in
            guard let mockConfig = configProvider else {
                return AsyncThrowingStream { continuation in
                    continuation.yield(nil)
                    continuation.finish(
                        throwing: DecodingError.valueNotFound(
                            Int.self,
                            DecodingError.Context(
                                codingPath: [],
                                debugDescription:
                                    "Expected a non-nil mockConfigProvider value"
                            )
                        )
                    )
                }
            }

            return mockAsyncStream(configProvider: mockConfig)
        }
    }

    static func mockAsyncStream(
        configProvider: ConfigurationProvider
    ) -> AsyncThrowingStream<ConfigurationProvider?, Error> {
        AsyncThrowingStream { continuation in
            continuation.yield(configProvider)
            continuation.finish()
        }
    }
}
