// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import CommonsLib

public struct CentralConfigurationRepository: CentralConfigurationRepositoryProtocol {

    private let centralConfigurationService: CentralConfigurationServiceProtocol

    public init(centralConfigurationService: CentralConfigurationServiceProtocol) {
        self.centralConfigurationService = centralConfigurationService
    }

    public func fetchConfiguration(
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async throws -> String {
        return try await centralConfigurationService.fetchConfiguration(
            proxyInfo: proxyInfo,
            userAgent: userAgent
        )
    }

    public func fetchSignature(
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async throws -> String {
        return try await centralConfigurationService.fetchSignature(
            proxyInfo: proxyInfo,
            userAgent: userAgent
        )
    }
}
