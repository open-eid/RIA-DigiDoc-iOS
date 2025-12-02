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
import Testing
import FactoryKit
import CommonsLib
import UtilsLib
import CommonsTestShared
import CommonsLibMocks

@testable import ConfigLib

struct ConfigurationCacheTests {

    private let mockFileManager: FileManagerProtocolMock

    private let configurationCache: ConfigurationCacheProtocol

    private let configDirectory: URL

    private let validConfData = TestConfigurationUtil.mockConfigurationResponse()
    private let validPublicKey = "valid public key"
    private let validSignature = "valid signature"

    init() async throws {
        self.mockFileManager = FileManagerProtocolMock()
        self.configurationCache = ConfigurationCache(fileManager: mockFileManager)
        self.configDirectory = try Directories.getConfigDirectory(fileManager: mockFileManager)
    }

    @Test
    func cacheConfigurationFiles_successWithValidData() async throws {
        let configurationCache = ConfigurationCache(fileManager: Container.shared.fileManager())
        let configDir = FileManager.default.temporaryDirectory.appending(path:
            "ConfigurationCacheTests-\(UUID().uuidString)"
        )
        let confFile = configDir.appending(path: CommonsLib.Constants.Configuration.CachedConfigJson)
        let pubFile = configDir.appending(path: CommonsLib.Constants.Configuration.CachedConfigPub)
        let sigFile = configDir.appending(path: CommonsLib.Constants.Configuration.CachedConfigRsa)

        try await configurationCache.cacheConfigurationFiles(
            confData: validConfData,
            publicKey: validPublicKey,
            signature: validSignature,
            configDir: configDir
        )

        let cachedConfiguration = try await configurationCache.getCachedFile(
            fileName: CommonsLib.Constants.Configuration.CachedConfigJson,
            configDir: configDir
        )

        let cachedPublicKey = try await configurationCache.getCachedFile(
            fileName: CommonsLib.Constants.Configuration.CachedConfigPub,
            configDir: configDir
        )

        let cachedSignature = try await configurationCache.getCachedFile(
            fileName: CommonsLib.Constants.Configuration.CachedConfigRsa,
            configDir: configDir
        )

        #expect(cachedConfiguration == confFile)
        #expect(cachedPublicKey == pubFile)
        #expect(cachedSignature == sigFile)
    }

    @Test
    func cacheConfigurationFiles_throwsErrorWhenFileURLNotFound() async throws {
        let nonExistentDirectoryURL = URL(string: "notURL")

        guard let nonExistentDirectory = nonExistentDirectoryURL else {
            Issue.record("Invalid URL")
            return
        }

        await #expect(
            throws: ConfigurationCacheError.unableToCacheFile(CommonsLib.Constants.Configuration.CachedConfigJson)
        ) {
            try await configurationCache.cacheConfigurationFiles(
                confData: validConfData,
                publicKey: validPublicKey,
                signature: validSignature,
                configDir: nonExistentDirectory
            )
        }
    }

    @Test
    func getCachedFile_throwsErrorWhenFileNotFound() async throws {
        let nonExistentFile = "non_existent_file.json"

        await #expect(
            throws: ConfigurationCacheError.fileNotFound
        ) {
            try await configurationCache.getCachedFile(
                fileName: nonExistentFile,
                configDir: configDirectory
            )
        }
    }

    @Test
    func getCachedFile_throwsErrorWhenFileURLNotFound() async throws {
        let nonExistentDirectoryURL = URL(string: "notURL")

        guard let nonExistentDirectory = nonExistentDirectoryURL else {
            Issue.record("Invalid URL")
            return
        }

        mockFileManager.fileExistsHandler = { _ in false }

        await #expect(
            throws: ConfigurationCacheError.fileNotFound
        ) {
            try await configurationCache.getCachedFile(
                fileName: CommonsLib.Constants.Configuration.CachedConfigJson,
                configDir: nonExistentDirectory
            )
        }
    }
}
