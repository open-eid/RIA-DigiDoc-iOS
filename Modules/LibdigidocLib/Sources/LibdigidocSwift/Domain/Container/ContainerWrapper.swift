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
import LibdigidocLibObjC
import CommonsLib
import UtilsLib

public actor ContainerWrapper: ContainerWrapperProtocol, Loggable {

    private var containerURL: URL
    private var dataFiles: [DataFileWrapper]
    private var signatures: [SignatureWrapper]
    private var mediatype: String

    private let fileManager: FileManagerProtocol

    @MainActor
    private let digiDocSigningWrapper: DigiDocSigningWrapper = DigiDocSigningWrapper()

    public init(
        containerURL: URL = URL(fileURLWithPath: ""),
        dataFiles: [DataFileWrapper] = [],
        signatures: [SignatureWrapper] = [],
        mediatype: String? = nil,
        fileManager: FileManagerProtocol
    ) {
        self.containerURL = containerURL
        self.dataFiles = dataFiles
        self.signatures = signatures
        self.mediatype = mediatype ?? CommonsLib.Constants.MimeType.Container
        self.fileManager = fileManager
    }

    public static func libdigidocppVersion() -> String {
        return DigiDocContainerWrapper.libdigidocppVersion()
    }

    public func getSignatures() async -> [SignatureWrapper] {
        return self.signatures
    }

    public func getDataFiles() async -> [DataFileWrapper] {
        return self.dataFiles
    }

    public func getMimetype() async -> String {
        return self.mediatype
    }

    public func getContainerURL() async -> URL {
        return self.containerURL
    }

    @MainActor
    public func saveDataFile(dataFile: DataFileWrapper, to directory: URL?) async throws -> URL {
        let savedFilesDirectory = try directory ?? Directories.getCacheDirectory(
            subfolders: [CommonsLib.Constants.Folder.SavedFiles],
            fileManager: fileManager
        )

        let allDataFiles = await getDataFiles()
        let sanitizedFilename = dataFile.fileName.sanitized()
        let index = allDataFiles.firstIndex { $0.fileId == dataFile.fileId } ?? 0
        let hasDuplicateName = allDataFiles.enumerated().contains { offset, other in
            offset != index && other.fileName.sanitized() == sanitizedFilename
        }
        let uniqueFilename = hasDuplicateName ? sanitizedFilename.appendingIndex(index) : sanitizedFilename

        let tempSavedFileLocation = savedFilesDirectory.appending(path: uniqueFilename)

        guard tempSavedFileLocation.isWithin(directory: savedFilesDirectory) else {
            throw DigiDocError.containerDataFileSavingFailed(
                ErrorDetail(
                    message: "Failed to save file",
                    userInfo: ["fileName": uniqueFilename]
                )
            )
        }

        do {
            try await DigiDocContainerWrapper.container(
                containerURL.resolvedPath,
                saveDataFile: dataFile.fileName,
                to: tempSavedFileLocation.resolvedPath
            )
            ContainerWrapper.logger().info(
                "Successfully saved \(uniqueFilename, privacy: .public) to 'Saved Files' directory"
            )
            return tempSavedFileLocation
        } catch {
            let nsError = (error as NSError?) ?? NSError(domain: "ContainerWrapper - cannot save data file", code: 2)
            throw DigiDocError.containerDataFileSavingFailed(
                ErrorDetail(nsError: nsError, extraInfo: ["fileName": tempSavedFileLocation.lastPathComponent])
            )
        }
    }

    @MainActor
    public func create(file: URL, dataFiles: [String]) async throws {
        do {
            return try await DigiDocContainerWrapper.create(file.resolvedPath, withDataFilePaths: dataFiles)
        } catch {
            let nsError = (error as NSError?) ?? NSError(domain: "ContainerWrapper - cannot create container", code: 1)
            throw DigiDocError.containerCreationFailed(
                ErrorDetail(nsError: nsError, extraInfo: ["fileName": file.lastPathComponent])
            )
        }
    }

    @MainActor
    public func open(containerFile: URL, isSivaConfirmed: Bool) async throws -> ContainerWrapper {
        ContainerWrapper.logger().info("Opening container file '\(containerFile.lastPathComponent, privacy: .public)'")

        do {
            let container = try DigiDocContainerWrapper.open(
                containerFile.resolvedPath,
                validateOnline: isSivaConfirmed
            )

            await setContainerURL(URL(fileURLWithPath: container.filePath))

            let datafiles = ContainerWrapper.getDataFiles(from: container)
            let signatures = ContainerWrapper.getSignatures(from: container)
            let mediatype = container.mediatype

            return await self.updateContainer(
                datafiles: datafiles,
                signatures: signatures,
                mediaType: mediatype
            )
        } catch {
            let nsError = (error as NSError?) ?? NSError(domain: "ContainerWrapper - cannot open container", code: 3)
            throw DigiDocError.containerOpeningFailed(
                ErrorDetail(
                    nsError: nsError,
                    extraInfo: ["fileName": containerFile.lastPathComponent])
            )
        }
    }

    @discardableResult
    @MainActor
    public func addDataFiles(containerFile: URL, dataFiles: [URL]) async throws -> ContainerWrapperProtocol {
        let dataFilesPaths = dataFiles.compactMap { $0.resolvedPath }
        do {
            try await DigiDocContainerWrapper.addDataFilesToContainer(
                withPath: containerFile.resolvedPath,
                withDataFilePaths: dataFilesPaths
            )

            return try await open(containerFile: containerFile, isSivaConfirmed: true)
        } catch {
            ContainerWrapper.logger().error("Unable to add data files. \(error, privacy: .public)")

            let nsError = error as NSError

            let errors = (nsError.userInfo["causes"] as? [String: Any])?["errors"] as? [NSError] ?? []

            let duplicatePrefix = "Document with same file name"

            let duplicateCount = errors.filter { $0.localizedDescription.hasPrefix(duplicatePrefix) }.count

            let failedCount = nsError.userInfo["failedFileCount"] as? Int ?? 0
            let totalCount = nsError.userInfo["totalFileCount"] as? Int ?? dataFilesPaths.count

            if duplicateCount == totalCount && totalCount > 1 {
                throw DigiDocError.addingFilesToContainerFailed(
                    ErrorDetail(message: "Multiple documents already exist", code: 4, userInfo: [
                        "totalFileCount": totalCount,
                        "failedFileCount": failedCount,
                        "duplicateFileCount": duplicateCount
                    ])
                )
            } else {
                let nsError = (error as NSError?) ?? NSError(
                    domain: "ContainerWrapper - cannot add data files",
                    code: 5
                )

                throw DigiDocError.addingFilesToContainerFailed(
                    ErrorDetail(
                        nsError: nsError,
                        extraInfo: ["duplicateFileCount": duplicateCount]
                    )
                )
            }
        }
    }

    @MainActor
    @discardableResult
    public func removeSignature(index: Int, containerFile: URL) async throws -> ContainerWrapperProtocol {
        do {
            try await DigiDocContainerWrapper.removeSignature(
                UInt(index),
                fromContainerWithPath: containerFile.resolvedPath
            )

            return try await open(containerFile: containerFile, isSivaConfirmed: true)
        } catch {
            let nsError = (error as NSError?) ?? NSError(domain: "ContainerWrapper - cannot remove signature", code: 5)
            throw DigiDocError.signatureRemovingFailed(
                ErrorDetail(
                    nsError: nsError
                )
            )
        }
    }

    @MainActor
    @discardableResult
    public func removeDataFile(index: Int, containerFile: URL) async throws -> ContainerWrapperProtocol {
        do {
            try await DigiDocContainerWrapper.removeDataFileFromContainer(
                withPath: containerFile.resolvedPath,
                at: UInt(index)
            )

            return try await open(containerFile: containerFile, isSivaConfirmed: true)
        } catch {
            let nsError = (error as NSError?) ?? NSError(domain: "ContainerWrapper - cannot remove datafile", code: 6)
            throw DigiDocError.dataFileRemovingFailed(
                ErrorDetail(
                    nsError: nsError
                )
            )
        }
    }

    @MainActor
    public func prepareSignature(
        cert: Data,
        containerPath: URL,
        roleData: RoleData?,
        userAgent: String
    ) async throws -> Data {
        return try await digiDocSigningWrapper
            .prepareSignature(
                cert,
                containerPath: containerPath.resolvedPath,
                roleData: DigiDocRoleData(
                    roles: roleData?.roles,
                    city: roleData?.city,
                    state: roleData?.state,
                    country: roleData?.country,
                    zipcode: roleData?.zipCode
                ),
                userAgent: userAgent
            )
    }

    @MainActor
    public func addSignature(signature: Data, containerFile: URL) async throws -> ContainerWrapperProtocol {

        do {
            try await digiDocSigningWrapper.addSignature(signature)

            return try await open(containerFile: containerFile, isSivaConfirmed: true)
        } catch {
            let nsError = (error as NSError?) ?? NSError(domain: "ContainerWrapper - cannot add signature", code: 7)
            throw DigiDocError.signatureAddingFailed(
                ErrorDetail(
                    nsError: nsError
                )
            )
        }
    }

    @discardableResult
    public func extendSignatureToLTA(containerFile: URL) async throws -> ContainerWrapperProtocol {
        do {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                DigiDocContainerWrapper.extendLastSignature(toLTA: containerFile.resolvedPath) { error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume()
                    }
                }
            }
            return try await open(containerFile: containerFile, isSivaConfirmed: true)
        } catch {
            let nsError = (error as NSError?) ??
                NSError(domain: "ContainerWrapper - cannot extend signature to LTA", code: 8)
            throw DigiDocError.signatureExtensionFailed(ErrorDetail(nsError: nsError))
        }
    }

    @discardableResult
    public func extendSignaturesToLTA(containerFile: URL) async throws -> ContainerWrapperProtocol {
        do {
            ContainerWrapper.logger().info("Extending signatures to LTA")
            let outputURL = containerFile
                .deletingPathExtension()
                .appendingPathExtension(CommonsLib.Constants.Extension.Asics)

            let savedPath: String = try await withCheckedThrowingContinuation { continuation in
                DigiDocContainerWrapper.extendContainer(
                    toLTA: containerFile.resolvedPath,
                    outputAsicsPath: outputURL.resolvedPath
                ) { resultPath, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: resultPath ?? containerFile.resolvedPath)
                    }
                }
            }

            let isWrappedIntoAsics = savedPath != containerFile.resolvedPath
            ContainerWrapper.logger().info(
                "Extended signatures to LTA. Wrapped into new ASiC-S: \(isWrappedIntoAsics, privacy: .public)"
            )

            if isWrappedIntoAsics {
                do {
                    try fileManager.removeItem(at: containerFile)
                } catch {
                    ContainerWrapper.logger().error(
                        "Unable to remove original container after wrapping to ASiC-S: \(error, privacy: .public)"
                    )
                }
            }

            return try await open(containerFile: URL(fileURLWithPath: savedPath), isSivaConfirmed: true)
        } catch {
            ContainerWrapper.logger().error("Unable to extend signatures to LTA: \(error, privacy: .public)")
            let nsError = (error as NSError?) ??
                NSError(domain: "ContainerWrapper - cannot extend signatures to LTA", code: 9)
            throw DigiDocError.signatureExtensionFailed(ErrorDetail(nsError: nsError))
        }
    }

    private static func signatureStatusToDigiDocStatus(_ status: DigiDocSignatureStatus) -> SignatureStatus {
        switch status {
        case .Valid:
            return .valid
        case .Warning:
            return .warning
        case .NonQSCD:
            return .nonQSCD
        case .Invalid:
            return .invalid
        case .UnknownStatus:
            return .unknown
        default:
            return .unknown
        }
    }

    @discardableResult
    private func updateContainer(
        datafiles: [DataFileWrapper],
        signatures: [SignatureWrapper],
        mediaType: String?
    ) async -> ContainerWrapper {
        self.dataFiles = datafiles
        self.signatures = signatures
        self.mediatype = mediaType ?? Constants.MimeType.Container

        return self
    }

    private func setContainerURL(_ url: URL) {
        self.containerURL = url
    }

    private static func getDataFiles(from container: DigiDocContainer) -> [DataFileWrapper] {
        guard let dataFiles = container.dataFiles as? NSArray else {
            return []
        }

        return dataFiles.compactMap { item in
            guard let dataFile = item as? DigiDocDataFile else {
                ContainerWrapper.logger().error("Unexpected type: \(type(of: item), privacy: .public)")
                return DataFileWrapper(fileId: "", fileName: "", fileSize: 0, mediaType: "")
            }

            return DataFileWrapper(
                fileId: dataFile.fileId,
                fileName: dataFile.fileName,
                fileSize: Int(dataFile.fileSize),
                mediaType: dataFile.mediaType
            )
        }
    }

    private static func getSignatures(from container: DigiDocContainer) -> [SignatureWrapper] {
        return container.signatures.compactMap { signature in
            SignatureWrapper(
                pos: Int(signature.pos),
                signingCert: signature.signingCert,
                timestampCert: signature.timestampCert,
                ocspCert: signature.ocspCert,
                signatureId: signature.signatureId,
                claimedSigningTime: signature.claimedSigningTime,
                signatureMethod: signature.signatureMethod,
                ocspProducedAt: signature.ocspProducedAt,
                timeStampTime: signature.timeStampTime,
                signedBy: signature.signedBy,
                trustedSigningTime: signature.trustedSigningTime,
                roles: signature.roles as? [String] ?? [],
                city: signature.city,
                state: signature.state,
                country: signature.country,
                zipCode: signature.zipCode,
                status: signatureStatusToDigiDocStatus(signature.status),
                format: signature.format,
                messageImprint: signature.messageImprint,
                diagnosticsInfo: signature.diagnosticsInfo,
                archiveTimestampTime: signature.archiveTimestampTime,
                archiveTimestampCert: signature.archiveTimestampCert
            )
        }
    }
}
