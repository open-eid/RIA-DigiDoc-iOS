// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import CommonsLib
import Foundation
import CryptoKit
import UtilsLib

public struct EncryptedDataUtil: EncryptedDataUtilProtocol, Loggable {

    private let fileManager: FileManagerProtocol

    public init(
        fileManager: FileManagerProtocol
    ) {
        self.fileManager = fileManager
    }

    // MARK: - Private Properties

    private func applicationSupportDirectory() -> URL? {
        return fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
    }

    // MARK: - Key Management

    public func getSymmetricKey(fileName: String) throws -> SymmetricKey {
        guard let appSupportDirectory = applicationSupportDirectory() else {
            EncryptedDataUtil.logger().error("Unable to locate Application Support directory")
            throw EncryptedDataError.unableToLocateAppSupportDirectory
        }

        let symmetricKeyURL = appSupportDirectory.appendingPathComponent(fileName)

        guard FileManager.default.fileExists(atPath: symmetricKeyURL.path) else {
            EncryptedDataUtil.logger().error("Key file does not exist at: \(symmetricKeyURL.path)")
            throw EncryptedDataError.keyFileDoesNotExist
        }

        let keyData = try Data(contentsOf: symmetricKeyURL)
        return SymmetricKey(data: keyData)
    }

    // MARK: - Encryption/Decryption

    public func decryptSecret(_ data: Data, with symmetricKey: SymmetricKey) -> String? {
        do {
            let sealedBox = try ChaChaPoly.SealedBox(combined: data)
            let decryptedData = try ChaChaPoly.open(sealedBox, using: symmetricKey)
            return String(data: decryptedData, encoding: .utf8)
        } catch {
            EncryptedDataUtil.logger().error("Unable to decrypt secret: \(error.localizedDescription)")
            return nil
        }
    }
}
