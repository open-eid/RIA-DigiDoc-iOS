// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import CommonsLib

/// @mockable
public protocol SignedContainerProtocol: GeneralContainer, Sendable {
    func getDataFiles() async -> [DataFileWrapper]
    func getSignatures() async -> [SignatureWrapper]
    func getTimestamps() async -> [SignatureWrapper]
    func getContainerName() async -> String
    func getContainerMimetype() async -> String
    func getRawContainerFile() async -> URL?
    @discardableResult func renameContainer(to newName: String) async throws -> SignedContainerProtocol
    @discardableResult func addDataFiles(
        _ dataFiles: [URL],
        to containerFile: URL
    ) async throws -> SignedContainerProtocol
    func saveDataFile(
        dataFile: DataFileWrapper,
        to directory: URL?
    ) async throws -> URL
    func isExistingContainer() async -> Bool
    func getNestedTimestampedContainer() async throws -> SignedContainerProtocol?
    func getSignaturesStatusCount() async -> [SignatureStatus: Int]
    func isEmptyFileInContainer() async -> Bool
    func isCades() async -> Bool
    func isXades() async -> Bool
    @discardableResult func removeSignature(index: Int, containerFile: URL) async throws -> SignedContainerProtocol
    @discardableResult func removeDataFile(index: Int, containerFile: URL) async throws -> SignedContainerProtocol
    func prepareSignature(
        cert: Data,
        containerPath: URL,
        roleData: RoleData,
        userAgent: String
    ) async throws -> Data
    func addSignature(signature: Data, containerFile: URL) async throws -> SignedContainerProtocol
    @discardableResult func extendSignature() async throws -> SignedContainerProtocol
    @discardableResult func extendSignatures() async throws -> SignedContainerProtocol
}

extension SignedContainerProtocol {
    func saveDataFile(dataFile: DataFileWrapper) async throws -> URL {
        try await saveDataFile(dataFile: dataFile, to: nil)
    }

    public func extendSignature(_ enabled: Bool) async throws -> any SignedContainerProtocol {
        guard enabled else { return self }
        let mimetype = await getContainerMimetype()
        guard mimetype != CommonsLib.Constants.MimeType.Ddoc else { return self }
        return try await extendSignature()
    }
}
