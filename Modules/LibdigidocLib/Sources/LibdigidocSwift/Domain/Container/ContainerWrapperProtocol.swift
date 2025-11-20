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

/// @mockable
public protocol ContainerWrapperProtocol: Sendable {
    func getVersion() async -> String
    func getSignatures() async -> [SignatureWrapper]
    func getDataFiles() async -> [DataFileWrapper]
    func getMimetype() async -> String
    func create(file: URL, dataFiles: [String]) async throws
    func open(containerFile: URL, isSivaConfirmed: Bool) async throws -> ContainerWrapper
    @discardableResult func addDataFiles(containerFile: URL, dataFiles: [URL]) async throws -> Bool
    func saveDataFile(containerFile: URL, dataFile: DataFileWrapper, to directory: URL?) async throws -> URL
    @discardableResult func removeSignature(index: Int, containerFile: URL) async throws -> ContainerWrapperProtocol
    @discardableResult func removeDataFile(index: Int, containerFile: URL) async throws -> ContainerWrapperProtocol
    func prepareSignature(
        cert: Data,
        containerPath: URL,
        roleData: RoleData?,
        userAgent: String
    ) async throws -> Data
    func addSignature(signature: Data, containerFile: URL) async throws -> ContainerWrapperProtocol
}

extension ContainerWrapperProtocol {
    func saveDataFile(containerFile: URL, dataFile: DataFileWrapper) async throws -> URL {
        try await saveDataFile(containerFile: containerFile, dataFile: dataFile, to: nil)
    }
}
