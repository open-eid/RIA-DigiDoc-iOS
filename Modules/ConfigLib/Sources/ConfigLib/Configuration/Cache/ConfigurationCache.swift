// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
