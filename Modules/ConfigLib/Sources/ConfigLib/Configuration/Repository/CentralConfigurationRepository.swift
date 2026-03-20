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
