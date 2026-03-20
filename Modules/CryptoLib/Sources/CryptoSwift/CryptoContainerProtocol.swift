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
import CommonsLib
import CryptoObjC
import CryptoObjCWrapper

/// @mockable
public protocol CryptoContainerProtocol: GeneralContainer, Sendable {
    func isDecrypted() async -> Bool
    func isEncrypted() async -> Bool
    func getContainerName() async -> String
    func getContainerMimetype() async -> String
    func getRawContainerFile() async -> URL?
    func addDataFiles(_ filesToAdd: [URL]) async
    func addRecipients(_ recipientsToAdd: [Addressee]) async

    func getDataFiles() async -> [URL]
    func getRecipients() async -> [Addressee]

    func removeRecipient(_ recipient: Addressee) async throws
    func removeDataFile(_ dataFile: URL) async throws

    @discardableResult func renameContainer(to newName: String) async throws -> URL
    func saveDataFile(dataFile: URL, to directory: URL?) async throws -> URL

}
