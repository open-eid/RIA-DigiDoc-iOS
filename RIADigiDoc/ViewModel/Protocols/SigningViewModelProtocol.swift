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
}
