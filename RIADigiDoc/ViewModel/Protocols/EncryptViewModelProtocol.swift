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
import CryptoSwift

/// @mockable
@MainActor
public protocol EncryptViewModelProtocol: Sendable {
    func loadContainerData(cryptoContainer: CryptoContainerProtocol?) async
    func createCopyOfContainerForSaving(containerURL: URL?) -> URL?
    func removeSavedFilesDirectory(savedFilesDirectory: URL?)
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
    func isContainerUnlocked(cryptoContainer: CryptoContainerProtocol?) async -> Bool
    func isEditButtonShown(cryptoContainer: CryptoContainerProtocol?, isNestedContainer: Bool) async -> Bool
    func isSignButtonShown(cryptoContainer: CryptoContainerProtocol?, isNestedContainer: Bool) async -> Bool
    func isShareButtonShown(cryptoContainer: CryptoContainerProtocol?) async -> Bool
    func isDecryptButtonShown(cryptoContainer: CryptoContainerProtocol?, isNestedContainer: Bool) async -> Bool
    func isEncryptButtonShown(cryptoContainer: CryptoContainerProtocol?, isNestedContainer: Bool) async -> Bool
    func removeDataFile(_ dataFile: URL) async
}
