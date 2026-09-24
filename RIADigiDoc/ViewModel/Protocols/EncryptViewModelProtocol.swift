// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import CryptoSwift
import CryptoObjCWrapper

/// @mockable
@MainActor
public protocol EncryptViewModelProtocol: Sendable {
    func loadContainerData(cryptoContainer: CryptoContainerProtocol?) async
    func createCopyOfContainerForSaving(containerURL: URL?) -> URL?
    func removeSavedFilesDirectory(savedFilesDirectory: URL?)
    func addDataFiles(_ files: [URL]) async throws
    func encryptContainer() async
    @discardableResult func renameContainer(to newName: String) async -> URL?
    func getDataFileURL(_ dataFile: URL) async -> Result<URL, Error>
    func handleFileOpening(dataFile: URL, isSivaConfirmed: Bool) async
    func handleSaveFile(dataFile: URL) async
    func isSivaConfirmationNeeded(dataFile: URL) async -> Bool
    func isEncryptedContainer(cryptoContainer: CryptoContainerProtocol?) async -> Bool
    func isDecryptedContainer(cryptoContainer: CryptoContainerProtocol?) async -> Bool
    func isContainerWithoutRecipients(cryptoContainer: CryptoContainerProtocol?) async -> Bool
    func isNestedContainer() -> Bool
    func handleBackButton() async -> Bool
    func isDataFilesInContainer(cryptoContainer: CryptoContainerProtocol?) async -> Bool
    func isCDOC1Container(cryptoContainer: CryptoContainerProtocol?) async -> Bool
    func shouldShowDataFiles(cryptoContainer: CryptoContainerProtocol?) async -> Bool
    func isInitialCryptoContainer(cryptoContainer: CryptoContainerProtocol?, isNestedContainer: Bool) async -> Bool
    func isUnlockedContainer(cryptoContainer: CryptoContainerProtocol?) async -> Bool
    func isEditButtonShown(cryptoContainer: CryptoContainerProtocol?, isNestedContainer: Bool) async -> Bool
    func isSignButtonShown(cryptoContainer: CryptoContainerProtocol?, isNestedContainer: Bool) async -> Bool
    func isShareButtonShown(cryptoContainer: CryptoContainerProtocol?) async -> Bool
    func isDecryptButtonShown(cryptoContainer: CryptoContainerProtocol?, isNestedContainer: Bool) async -> Bool
    func isEncryptButtonShown(cryptoContainer: CryptoContainerProtocol?, isNestedContainer: Bool) async -> Bool
    func isRecipientRemoveButtonShown() -> Bool
    func removeRecipient(_ recipient: Addressee) async
    func removeDataFile(_ dataFile: URL) async
    func updateAsyncProperties() async
    func convertToSignedContainer() async -> Bool
}
