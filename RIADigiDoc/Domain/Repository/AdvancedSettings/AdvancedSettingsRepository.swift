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
import OSLog
import UniformTypeIdentifiers
import UtilsLib
import CommonsLib

actor AdvancedSettingsRepository: AdvancedSettingsRepositoryProtocol {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "AdvancedSettingsRepository")

    private let fileManager: FileManagerProtocol
    private let certificateUtil: CertificateUtilProtocol

    init(
        fileManager: FileManagerProtocol,
        certificateUtil: CertificateUtilProtocol
    ) {
        self.fileManager = fileManager
        self.certificateUtil = certificateUtil
    }

    // MARK: - Loading Certificate

    func getCertificate(
        certificateFolder: String,
        certificateBaseName: String,
    ) async -> Data? {
        do {
            guard let certFileURL = try
                    getCertificateFileURL(
                        certificateFolder: certificateFolder,
                        certificateBaseName: certificateBaseName
                    )
            else { return nil }
            return try await getCertificateContent(certFileURL: certFileURL)
        } catch {
            await AdvancedSettingsRepository.logger.error("Unable to load certificate: \(error)")
            return nil
        }
    }

    private func getCertificateFileURL(
        certificateFolder: String,
        certificateBaseName: String
    ) throws -> URL? {
        let certCacheDirectory = try Directories.getCacheDirectory(
            subfolder: certificateFolder,
            fileManager: fileManager
        )
        guard fileManager.fileExists(atPath: certCacheDirectory.resolvedPath) else { return nil }

        let files = try fileManager.contentsOfDirectory(
            at: certCacheDirectory,
            includingPropertiesForKeys: nil,
            options: []
        )

        return files.first {
            $0.deletingPathExtension().lastPathComponent == certificateBaseName
        }
    }

    private func getCertificateContent(certFileURL: URL) async throws -> Data? {
        let certDataRaw = try Data(contentsOf: certFileURL)
        var certData = certDataRaw
        if let der = await certificateUtil.pemToDerData(fromPEM: certDataRaw) {
            certData = der
        }
        return certData
    }

    // MARK: - Import Certificate

    func importCertificate(
        from url: URL,
        certificateFolder: String,
        certificateBaseName: String
    ) async -> Data? {
        do {
            let certCacheDirectory = try Directories.getCacheDirectory(
                subfolder: certificateFolder,
                fileManager: fileManager
            )

            try removeAllCertFiles(certCacheDirectory: certCacheDirectory)

            let sourceExtension = url.pathExtension
            let extensionToUse = sourceExtension.isEmpty ? "cer" : sourceExtension
            let destinationURL = certCacheDirectory.appending(path:
                "\(certificateBaseName).\(extensionToUse)"
            )

            try fileManager.copyItem(at: url, to: destinationURL)

            return try await getCertificateContent(certFileURL: destinationURL)
        } catch {
            await AdvancedSettingsRepository.logger.error("Unable to import certificate: \(error)")
            return nil
        }
    }

    private func removeAllCertFiles(certCacheDirectory: URL) throws {
        let extensions = UTType.x509Certificate.tags[.filenameExtension]?.map { $0.lowercased() } ?? []
        let existingCerts = try fileManager.contentsOfDirectory(
            at: certCacheDirectory,
            includingPropertiesForKeys: nil,
            options: []
        ).filter { extensions.contains($0.pathExtension.lowercased()) }

        for certURL in existingCerts {
            try fileManager.removeItem(at: certURL)
        }
    }

    public func removeAllCertFiles(certificateFolders: [String]) async throws {
        for certificateFolder in certificateFolders {
            let certCacheDirectory = try Directories.getCacheDirectory(
                subfolder: certificateFolder,
                fileManager: fileManager
            )
            try removeAllCertFiles(certCacheDirectory: certCacheDirectory)
        }
    }
}
