// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
    func addDataFiles(_ filesToAdd: [URL]) async throws
    func addRecipients(_ recipientsToAdd: [Addressee]) async

    func getDataFiles() async -> [URL]
    func getRecipients() async -> [Addressee]

    func removeRecipient(_ recipient: Addressee) async throws
    func removeDataFile(_ dataFile: URL) async throws

    @discardableResult func renameContainer(to newName: String) async throws -> URL
    func saveDataFile(dataFile: URL, to directory: URL?) async throws -> URL

}
