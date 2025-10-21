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

/// @mockable
public protocol SignedContainerProtocol: Sendable, AnyObject {
    func getDataFiles() async -> [DataFileWrapper]
    func getSignatures() async -> [SignatureWrapper]
    func getTimestamps() async -> [SignatureWrapper]
    func getContainerName() async -> String
    func getContainerMimetype() async -> String
    func getRawContainerFile() async -> URL?
    @discardableResult func renameContainer(to newName: String) async throws -> URL
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
}

extension SignedContainerProtocol {
    func saveDataFile(dataFile: DataFileWrapper) async throws -> URL {
        try await saveDataFile(dataFile: dataFile, to: nil)
    }
}
