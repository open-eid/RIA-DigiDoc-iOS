import Foundation
import OSLog
import UniformTypeIdentifiers
import UtilsLib
import CommonsLib

actor AdvancedSettingsRepository: AdvancedSettingsRepositoryProtocol {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "AdvancedSettingsRepository")

    private let fileManager: FileManagerProtocol

    init(
        fileManager: FileManagerProtocol,
    ) {
        self.fileManager = fileManager
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
        guard fileManager.fileExists(atPath: certCacheDirectory.path) else { return nil }

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
        if let der = await CertificateUtil.pemToDerData(fromPEM: certDataRaw) {
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

            if !fileManager.fileExists(atPath: certCacheDirectory.path) {
                try fileManager.createDirectory(
                    at: certCacheDirectory,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            }

            try removeAllCertFiles(certCacheDirectory: certCacheDirectory)

            let sourceExtension = url.pathExtension
            let extensionToUse = sourceExtension.isEmpty ? "cer" : sourceExtension
            let destinationURL = certCacheDirectory.appendingPathComponent(
                "\(certificateBaseName).\(extensionToUse)"
            )

            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.copyItem(at: url, to: destinationURL)

            let certData = try await getCertificateContent(certFileURL: url)

            return certData
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
}
