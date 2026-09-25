// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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

    // MARK: - decryptSecret tests

    private func seal(_ secret: String, with key: SymmetricKey) throws -> Data {
        try ChaChaPoly.seal(Data(secret.utf8), using: key).combined
    }

    @Test
    func decryptSecret_success() async throws {
        let testSecret = "mySecretData"
        let key = SymmetricKey(size: .bits256)

        let decryptedSecret = encryptedDataUtil.decryptSecret(try seal(testSecret, with: key), with: key)

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
        let key1 = SymmetricKey(size: .bits256)
        let key2 = SymmetricKey(size: .bits256)

        let result = encryptedDataUtil.decryptSecret(try seal("secretData", with: key1), with: key2)

        #expect(result == nil)
    }

    @Test
    func decryptSecret_worksWithSpecialChars() async throws {
        let testSecret = "This is a test secret with special chars: !@#$%^&*()"
        let key = SymmetricKey(size: .bits256)

        let decrypted = encryptedDataUtil.decryptSecret(try seal(testSecret, with: key), with: key)

        #expect(decrypted == testSecret)
    }

    @Test
    func decryptSecret_worksWithEmptyString() async throws {
        let testSecret = ""
        let key = SymmetricKey(size: .bits256)

        let decrypted = encryptedDataUtil.decryptSecret(try seal(testSecret, with: key), with: key)

        #expect(decrypted == testSecret)
    }
}
