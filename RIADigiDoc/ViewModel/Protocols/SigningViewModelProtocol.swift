// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import LibdigidocLibSwift

/// @mockable
@MainActor
public protocol SigningViewModelProtocol: Sendable {
    func loadContainerData(signedContainer: SignedContainerProtocol?) async
    func createCopyOfContainerForSaving(containerURL: URL?) -> URL?
    func removeSavedFilesDirectory(savedFilesDirectory: URL?)
    func addDataFiles(_ files: [URL], to container: URL) async
    @discardableResult func renameContainer(to newName: String) async -> URL?
    func getDataFileURL(_ dataFile: DataFileWrapper) async -> Result<URL, Error>
    func handleFileOpening(dataFile: DataFileWrapper, isSivaConfirmed: Bool) async
    func handleSaveFile(dataFile: DataFileWrapper) async
    func isNestedContainer() -> Bool
    func isSivaConfirmationNeeded(dataFile: DataFileWrapper) async -> Bool
    func isSignButtonShown(signedContainer: SignedContainerProtocol?, isNestedContainer: Bool) async -> Bool
    func isEncryptButtonShown(signedContainer: SignedContainerProtocol?, isNestedContainer: Bool) async -> Bool
    func isSignatureRemoveButtonShown() -> Bool
    func isTimestampedContainer() async -> Bool
    func getContainerNotifications(container: SignedContainerProtocol) async -> [ContainerNotificationType]
    func removeSignature(_ signature: SignatureWrapper) async
    func removeDataFile(_ dataFile: DataFileWrapper) async
    func isSignatureAdded() -> Bool
    func removeLastOpenedXattr(from url: URL)
    func resetErrorMessage()
    func resetSuccessMessage()
    func convertToCryptoContainer() async -> Bool
    func extendSignatures() async
}
