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
