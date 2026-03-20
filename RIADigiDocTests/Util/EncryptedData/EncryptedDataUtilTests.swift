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
import CommonsTestShared
import CryptoKit
import Foundation
import Testing
import UtilsLib

@MainActor
final class EncryptedDataUtilTests {
    private let encryptedDataUtil: EncryptedDataUtil

    private let mockFileManager: FileManagerProtocolMock

    public init() async throws {
        mockFileManager = FileManagerProtocolMock()

        encryptedDataUtil = EncryptedDataUtil(
            fileManager: mockFileManager
        )
    }

    // MARK: - saveSymmetricKeyToAppSupport tests

    @Test
    func saveSymmetricKeyToAppSupport_throwsWhenDirectoryNotFound() async throws {
        mockFileManager.urlsHandler = { _, _ in
            return []
        }

        #expect(throws: EncryptedDataError.self) {
            try encryptedDataUtil.saveSymmetricKeyToAppSupport(fileName: "test.key")
        }
    }

    @Test
    func saveSymmetricKeyToAppSupport_success() async throws {
        let tempDirectory = try TestFileUtil.getTemporaryDirectory(subfolder: "keys")
        defer {
            try? FileManager.default.removeItem(at: tempDirectory)
        }

        mockFileManager.urlsHandler = { _, _ in
            return [tempDirectory]
        }

        let fileName = "test_\(UUID().uuidString).key"
        let resultURL = try encryptedDataUtil.saveSymmetricKeyToAppSupport(fileName: fileName)
        defer {
            try? FileManager.default.removeItem(at: resultURL)
        }

        #expect(resultURL.lastPathComponent == fileName)
        #expect(mockFileManager.urlsCallCount == 1)
    }

    // MARK: - getSymmetricKey tests

    @Test
    func getSymmetricKey_throwsWhenDirectoryNotFound() async throws {
        mockFileManager.urlsHandler = { _, _ in
            return []
        }

        #expect(throws: EncryptedDataError.self) {
            try encryptedDataUtil.getSymmetricKey(fileName: "test.key")
        }
    }

    @Test
    func getSymmetricKey_throwsWhenFileDoesNotExist() async throws {
        let tempDirectory = try TestFileUtil.getTemporaryDirectory(subfolder: "keys")
        defer {
            try? FileManager.default.removeItem(at: tempDirectory)
        }

        mockFileManager.urlsHandler = { _, _ in
            return [tempDirectory]
        }

        #expect(throws: EncryptedDataError.self) {
            try encryptedDataUtil.getSymmetricKey(fileName: "nonexistent_\(UUID().uuidString).key")
        }
    }

    @Test
    func getSymmetricKey_success() async throws {
        let tempDirectory = try TestFileUtil.getTemporaryDirectory(subfolder: "keys")
        defer {
            try? FileManager.default.removeItem(at: tempDirectory)
        }
        let fileName = "test_\(UUID().uuidString).key"
        let fileURL = tempDirectory.appendingPathComponent(fileName)

        let testKey = SymmetricKey(size: .bits256)
        let keyData = testKey.withUnsafeBytes { Data($0) }
        try keyData.write(to: fileURL, options: .atomic)

        mockFileManager.urlsHandler = { _, _ in
            return [tempDirectory]
        }

        let retrievedKey = try encryptedDataUtil.getSymmetricKey(fileName: fileName)

        #expect(mockFileManager.urlsCallCount == 1)

        retrievedKey.withUnsafeBytes { bytes in
            #expect(bytes.count == 32)
        }
    }

    // MARK: - encryptSecret tests

    @Test
    func encryptSecret_success() async throws {
        let testSecret = "mySecretPassword123"
        let key = SymmetricKey(size: .bits256)

        let encryptedData = encryptedDataUtil.encryptSecret(testSecret, with: key)

        #expect(encryptedData != nil)
        guard let encryptedData else { return }
        #expect(encryptedData.count > 0)
    }

    // MARK: - decryptSecret tests

    @Test
    func decryptSecret_success() async throws {
        let testSecret = "mySecretData"
        let key = SymmetricKey(size: .bits256)

        guard let encryptedData = encryptedDataUtil.encryptSecret(testSecret, with: key) else {
            Issue.record("Failed to encrypt secret")
            return
        }

        let decryptedSecret = encryptedDataUtil.decryptSecret(encryptedData, with: key)

        #expect(decryptedSecret == testSecret)
    }

    @Test
    func decryptSecret_returnsNilForInvalidData() async throws {
        let key = SymmetricKey(size: .bits256)
        let invalidData = Data([0x00, 0x01, 0x02, 0x03])

        let result = encryptedDataUtil.decryptSecret(invalidData, with: key)

        #expect(result == nil)
    }

    @Test
    func decryptSecret_returnsNilForWrongKey() async throws {
        let testSecret = "secretData"
        let key1 = SymmetricKey(size: .bits256)
        let key2 = SymmetricKey(size: .bits256)

        guard let encryptedData = encryptedDataUtil.encryptSecret(testSecret, with: key1) else {
            Issue.record("Failed to encrypt secret")
            return
        }

        let result = encryptedDataUtil.decryptSecret(encryptedData, with: key2)

        #expect(result == nil)
    }

    @Test
    func encryptDecrypt_worksWithSpecialChars() async throws {
        let testSecret = "This is a test secret with special chars: !@#$%^&*()"
        let key = SymmetricKey(size: .bits256)

        let encrypted = encryptedDataUtil.encryptSecret(testSecret, with: key)
        #expect(encrypted != nil)
        guard let encrypted else { return }

        let decrypted = encryptedDataUtil.decryptSecret(encrypted, with: key)
        #expect(decrypted == testSecret)
    }

    @Test
    func encryptDecrypt_worksWithEmptyString() async throws {
        let testSecret = ""
        let key = SymmetricKey(size: .bits256)

        let encrypted = encryptedDataUtil.encryptSecret(testSecret, with: key)
        #expect(encrypted != nil)
        guard let encrypted else { return }

        let decrypted = encryptedDataUtil.decryptSecret(encrypted, with: key)
        #expect(decrypted == testSecret)
    }
}
