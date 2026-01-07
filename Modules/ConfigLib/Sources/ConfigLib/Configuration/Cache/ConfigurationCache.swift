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
import FactoryKit
import CommonsLib
import UtilsLib

actor ConfigurationCache: ConfigurationCacheProtocol, Loggable {

    private let fileManager: FileManagerProtocol

    init(
        fileManager: FileManagerProtocol
    ) {
        self.fileManager = fileManager
    }

    public func cacheConfigurationFiles(
        confData: String,
        publicKey: String,
        signature: String,
        configDir: URL
    ) async throws {
        guard let confDataBytes = confData.data(using: .utf8) else {
            throw ConfigurationCacheError.invalidData("Invalid UTF-8 encoding for confData")
        }

        try await cacheFile(
            fileName: CommonsLib.Constants.Configuration.CachedConfigJson,
            data: confDataBytes,
            configDir: configDir
        )

        guard let publicKeyBytes = publicKey.data(using: .utf8) else {
            throw ConfigurationCacheError.invalidData("Invalid UTF-8 encoding for publicKey")
        }

        try await cacheFile(
            fileName: CommonsLib.Constants.Configuration.CachedConfigEcPub,
            data: publicKeyBytes,
            configDir: configDir
        )

        guard let signatureBytes = signature.data(using: .utf8) else {
            throw ConfigurationCacheError.invalidData("Invalid UTF-8 encoding for signature")
        }

        try await cacheFile(
            fileName: CommonsLib.Constants.Configuration.CachedConfigEcc,
            data: signatureBytes,
            configDir: configDir
        )
    }

    public func getCachedFile(
        fileName: String,
        configDir: URL
    ) async throws -> URL {
        let configFile = configDir.appending(path: fileName)

        guard fileManager.fileExists(atPath: configFile.resolvedPath) else {
            throw ConfigurationCacheError.fileNotFound
        }
        return configFile
    }

    private func cacheFile(
        fileName: String,
        data: Data,
        configDir: URL
    ) async throws {
        let configFile = configDir.appending(path: fileName)

        do {
            try fileManager.createDirectory(
                at: configDir,
                withIntermediateDirectories: true,
                attributes: nil
            )

            try data.write(to: configFile)
        } catch {
            ConfigurationCache.logger().error("\(error.localizedDescription)")
            throw ConfigurationCacheError.unableToCacheFile(fileName)
        }
    }
}
