// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import CommonsLib

/// @mockable
public protocol ContainerWrapperProtocol: Sendable {
    func getSignatures() async -> [SignatureWrapper]
    func getDataFiles() async -> [DataFileWrapper]
    func getMimetype() async -> String
    func getContainerURL() async -> URL
    func create(file: URL, dataFiles: [String]) async throws
    func open(containerFile: URL, isSivaConfirmed: Bool) async throws -> ContainerWrapper
    @discardableResult func addDataFiles(containerFile: URL, dataFiles: [URL]) async throws -> ContainerWrapperProtocol
    func saveDataFile(dataFile: DataFileWrapper, to directory: URL?) async throws -> URL
    @discardableResult func removeSignature(index: Int, containerFile: URL) async throws -> ContainerWrapperProtocol
    @discardableResult func removeDataFile(index: Int, containerFile: URL) async throws -> ContainerWrapperProtocol
    func prepareSignature(
        cert: Data,
        containerPath: URL,
        roleData: RoleData?,
        userAgent: String
    ) async throws -> Data
    func addSignature(signature: Data, containerFile: URL) async throws -> ContainerWrapperProtocol
    @discardableResult func extendSignatureToLTA(containerFile: URL) async throws -> ContainerWrapperProtocol
    @discardableResult func extendSignaturesToLTA(containerFile: URL) async throws -> ContainerWrapperProtocol
}

extension ContainerWrapperProtocol {
    func saveDataFile(dataFile: DataFileWrapper) async throws -> URL {
        try await saveDataFile(dataFile: dataFile, to: nil)
    }
}
