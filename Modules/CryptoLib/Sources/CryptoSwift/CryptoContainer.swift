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
import FactoryKit
import CryptoObjC
import CryptoObjCWrapper
import IdCardLib
import CommonsLib
import UtilsLib

public actor CryptoContainer: CryptoContainerProtocol, Loggable {

    private static let cryptoContainerLogTag: String = "CryptoContainer"

    private var containerFile: URL?
    private let fileManager: FileManagerProtocol
    private let containerUtil: ContainerUtilProtocol
    private var dataFiles: [URL?]?
    private var recipients: [Addressee?]?
    private let isDecrypted: Bool
    private let isEncrypted: Bool

    public init(
        containerFile: URL? = nil,
        fileManager: FileManagerProtocol,
        containerUtil: ContainerUtilProtocol,
        dataFiles: [URL?]? = [],
        recipients: [Addressee?]? = [],
        isDecrypted: Bool = false,
        isEncrypted: Bool = false,
    ) {
        self.containerFile = containerFile
        self.fileManager = fileManager
        self.containerUtil = containerUtil
        self.dataFiles = dataFiles
        self.recipients = recipients
        self.isDecrypted = isDecrypted
        self.isEncrypted = isEncrypted
    }

    public func isDecrypted() async -> Bool {
        return isDecrypted
    }

    public func isEncrypted() async -> Bool {
        return isEncrypted
    }

    public func getContainerName() async -> String {
        return containerFile?.lastPathComponent ?? CommonsLib.Constants.Container.DefaultName
    }

    public func getContainerMimetype() async -> String {
        return CommonsLib.Constants.MimeType.Container
    }

    public func getRawContainerFile() async -> URL? {
        return containerFile
    }

    public func addDataFiles(_ filesToAdd: [URL]) async throws {
        let cryptoContainersDirectory = try Directories.getCacheDirectory(
            subfolders: [Constants.Folder.ContainerFolder, Constants.Folder.Temp],
            fileManager: fileManager
        )

        var movedFiles: [URL] = []
        var duplicateFileCount = 0
        var failedFileCount = 0
        let totalFileCount = filesToAdd.count

        let existingDataFiles = Set(dataFiles?.compactMap { $0?.lastPathComponent } ?? [])

        var duplicateFileName: String?

        for fileToAdd in filesToAdd {
            let fileName = fileToAdd.lastPathComponent
            let destinationURL = cryptoContainersDirectory.appendingPathComponent(fileName)

            if existingDataFiles.contains(fileName) ||
                movedFiles.contains(where: { $0.lastPathComponent == fileName }) {

                duplicateFileCount += 1

                if duplicateFileCount == 1 {
                    duplicateFileName = fileName
                }

                continue
            }

            do {
                if fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                }

                try fileManager.copyItem(at: fileToAdd, to: destinationURL)
                movedFiles.append(destinationURL)

            } catch {
                failedFileCount += 1
            }
        }

        if dataFiles == nil {
            dataFiles = movedFiles
        } else {
            dataFiles?.append(contentsOf: movedFiles)
        }

        if duplicateFileCount > 0 || failedFileCount > 0 {
            var userInfo: [String: String] = [
                "totalFileCount": String(totalFileCount),
                "failedFileCount": String(failedFileCount),
                "duplicateFileCount": String(duplicateFileCount)
            ]

            if duplicateFileCount == 1, let name = duplicateFileName {
                userInfo["fileName"] = name
            }

            throw CryptoError.addingFilesToContainerFailed(
                CryptoErrorDetail(
                    message: "Unable to add files to container",
                    userInfo: userInfo
                )
            )
        }
    }

    public func addRecipients(_ recipientsToAdd: [Addressee]) async {
        recipients?.append(contentsOf: recipientsToAdd)
    }

    public func getDataFiles() async -> [URL] {
        guard let dataFiles else {
            return []
        }
        return dataFiles.compactMap { $0 }
    }

    public func getRecipients() async -> [Addressee] {
        guard let recipients else {
            return []
        }
        return recipients.compactMap { $0 }
    }

    public func removeRecipient(_ recipient: Addressee) async throws {
        let localRecipients = await getRecipients()
        guard !localRecipients.isEmpty else { return }

        for (index, rec) in localRecipients.enumerated()
            where recipient.data == rec.data {
                recipients?.remove(at: index)
                break
        }
    }

    public func removeDataFile(_ dataFile: URL) async throws {
        let localDataFiles = await getDataFiles()
        guard !localDataFiles.isEmpty else { return }

        for (index, file) in localDataFiles.enumerated()
        where dataFile.lastPathComponent == file.lastPathComponent {
                dataFiles?.remove(at: index)
                break
        }
    }

    @discardableResult
    public func renameContainer(to newName: String) async throws -> URL {
        let fileName = newName.isEmpty ? CommonsLib.Constants.Container.DefaultName : newName

        let sanitizedFileName = fileName.sanitized()
        let normalizedPath = URL(fileURLWithPath: sanitizedFileName).standardizedPathURL

        guard let currentURL = containerFile else {
            throw CryptoError.containerRenamingFailed(
                CryptoErrorDetail(
                    message: "Unable to rename container. Current URL is nil",
                    userInfo: ["fileName": containerFile?.lastPathComponent ?? ""]
                )
            )
        }

        let newFileName = normalizedPath.lastPathComponent
        guard !newFileName.isEmpty else {
            throw CryptoError.containerRenamingFailed(
                CryptoErrorDetail(
                    message: "Unable to rename container. New filename is empty",
                    userInfo: ["fileName": currentURL.lastPathComponent]
                )
            )
        }

        let destinationURL = currentURL
            .deletingLastPathComponent()
            .appending(path: newFileName)

        let uniqueFileURL = containerUtil.getContainerFile(
            for: destinationURL,
            in: destinationURL.deletingLastPathComponent()
        )

        containerFile = uniqueFileURL

        return uniqueFileURL
    }

    private func save(_ source: URL, as destination: URL) throws {
        try fileManager.copyItem(at: source, to: destination)
    }

    public func saveDataFile(dataFile: URL, to directory: URL?) async throws -> URL {
        let sanitizedName = dataFile.lastPathComponent.sanitized()
        let savedFilesDirectory = try directory ?? Directories.getCacheDirectory(
            subfolders: [CommonsLib.Constants.Folder.SavedFiles],
            fileManager: fileManager
        )
        let file = savedFilesDirectory.appending(path: sanitizedName)
        let dataFiles = await getDataFiles()

        for containerDataFile in dataFiles
        where dataFile.lastPathComponent == containerDataFile.lastPathComponent {
                if !fileManager.fileExists(atPath: file.resolvedPath) {
                    try save(containerDataFile, as: file)
                }
                return file
        }
        throw CryptoError.containerDataFileSavingFailed(
            CryptoErrorDetail(
                message: "Could not find file in container",
                userInfo: ["fileName": dataFile.lastPathComponent]
            )
        )
    }
}

extension CryptoContainer {

    @MainActor
    public static func enableLogging(_ bool: Bool) {
        Encrypt.enableLogging(bool)
    }

    @MainActor
    public static func openOrCreate(
        dataFiles: [URL],
        containerUtil: ContainerUtilProtocol = Container.shared.containerUtil(),
    ) async throws -> CryptoContainerProtocol {
        logger().info("Opening or creating crypto container. Found \(dataFiles.count) datafile(s)")
        guard let firstFile = dataFiles.first else {
            logger().error("Unable to create or open crypto container. First datafile is nil")
            throw CryptoError.containerCreationFailed(
                CryptoErrorDetail(
                    message: "Cannot create or open crypto container. Datafiles are empty"
                )
            )
        }

        let isSingleFile = dataFiles.count == 1
        let isCryptoContainer = await firstFile.isCryptoContainer()

        CryptoContainer.logger().info("Is single file: \(isSingleFile, privacy: .public)")
        CryptoContainer.logger().info("Is crypto container: \(isCryptoContainer, privacy: .public)")

        guard isSingleFile && isCryptoContainer else {
            var defaultExtension = CommonsLib.Constants.Extension.DefaultCrypto
            if CDoc2Setting.isEncryptionEnabled {
                defaultExtension = CommonsLib.Constants.Extension.Cdoc2
            } else {
                defaultExtension = CommonsLib.Constants.Extension.Cdoc
            }

            let containerURL: URL
            if firstFile.pathExtension != defaultExtension {
                containerURL = firstFile
                    .deletingPathExtension()
                    .appendingPathExtension(defaultExtension)
            } else {
                containerURL = firstFile
            }

            let fileManager = Container.shared.fileManager()

            let cryptoContainersDirectory = try Directories.getCacheDirectory(
                subfolders: [Constants.Folder.ContainerFolder],
                fileManager: fileManager
            )

            CryptoContainer.logger().info("Getting an unique crypto container name")
            // Get unique container name file (1) if name already exists
            let uniqueContainerURL = containerUtil.getContainerFile(
                for: containerURL,
                in: cryptoContainersDirectory
            )

            CryptoContainer.logger().info("Creating a new crypto container")
            return try await create(
                containerFile: uniqueContainerURL,
                dataFiles: dataFiles,
                recipients: [],
                isDecrypted: false,
                isEncrypted: false
            )
        }

        CryptoContainer.logger().info("Opening existing crypto container")
        return try await open(containerFile: firstFile)
    }

    @MainActor
    public static func decrypt(
        containerFile: URL,
        recipients: [Addressee],
        cert: Data,
        cardCommands: CardCommands,
        pin: SecureData,
        fileManager: FileManagerProtocol = Container.shared.fileManager()
    ) async throws -> CryptoContainerProtocol {

        let decryptedData =
            try await Decrypt.decryptFile(
                containerFile.resolvedPath,
                withCert: cert,
                withToken: SmartToken(card: cardCommands, pin1: pin)
            )
        var cryptoDataFiles: [CryptoDataFile] = []
        var urlDataFiles: [URL] = []
        cryptoDataFiles.removeAll()
        for dataFile in decryptedData {

            let sanitizedName = dataFile.key.sanitized()

            let destinationPath = try Directories.getCacheDirectory(
                subfolders: [Constants.Folder.ContainerFolder, Constants.Folder.Temp],
                fileManager: fileManager
            )

            let fileUrl = destinationPath.appending(path: sanitizedName, directoryHint: .notDirectory)

            cryptoDataFiles.append(CryptoDataFile(filename: dataFile.key, filePath: destinationPath.resolvedPath))
            urlDataFiles.append(fileUrl)
            let isCreated = fileManager.createFile(
                atPath: fileUrl.resolvedPath, contents: dataFile.value, attributes: nil
            )

            if !isCreated {
                CryptoContainer.logger().error("Unable to create file at path: \(destinationPath.resolvedPath)")
            }
        }

        return try await create(
            containerFile: containerFile,
            dataFiles: urlDataFiles,
            recipients: recipients,
            isDecrypted: true,
            isEncrypted: false
        )
    }

    @MainActor
    public static func encrypt(
        containerFile: URL,
        dataFiles: [URL],
        recipients: [Addressee]
    ) async throws -> CryptoContainerProtocol {
        if dataFiles.isEmpty {
            throw CryptoError.containerCreationFailed(
                CryptoErrorDetail(
                    message: "Cannot create an empty crypto container"
                )
            )
        }

        if recipients.isEmpty {
            throw CryptoError.containerCreationFailed(
                CryptoErrorDetail(
                    message: "Cannot create crypto container without recipients"
                )
            )
        }
        var cryptoDataFiles: [CryptoDataFile] = []

        for dataFile in dataFiles {

            cryptoDataFiles.append(
                CryptoDataFile(
                    filename: dataFile.lastPathComponent,
                    filePath: dataFile.resolvedPath
                )
            )
        }

        try await Encrypt.encryptFile(
            containerFile.resolvedPath,
            withDataFiles: cryptoDataFiles,
            withAddressees: recipients
        )

        return try await open(containerFile: containerFile)
    }

    private static func open(containerFile: URL) async throws -> CryptoContainerProtocol {
        let fileManager = Container.shared.fileManager()

        let cryptoContainersDirectory = try Directories.getCacheDirectory(
            subfolders: [Constants.Folder.ContainerFolder],
            fileManager: fileManager
        )

        let savedContainersDirectory = try Directories.getCacheDirectory(
            subfolders: [Constants.Folder.SavedFiles],
            fileManager: fileManager
        )

        // Do not rename when nested container opened
        let isFileInSavedContainersDirectory = containerFile.absoluteString.hasPrefix(
            savedContainersDirectory.absoluteString
        )

        let isFileInRecentDocuments = containerFile.absoluteString.hasPrefix(
            cryptoContainersDirectory.absoluteString
        )

        let shouldRenameContainer = isFileInRecentDocuments && !isFileInSavedContainersDirectory

        var renamedContainerFile = containerFile

        if shouldRenameContainer {
            renamedContainerFile = Container.shared.containerUtil().getContainerFile(
                for: containerFile,
                in: isFileInRecentDocuments ? containerFile.deletingLastPathComponent() :
                    containerFile.deletingLastPathComponent().deletingLastPathComponent()
            )

            try fileManager.moveItem(at: containerFile, to: renamedContainerFile)
        }

        guard let cdocInfo = try Decrypt.cdocInfo(renamedContainerFile.resolvedPath) as? CdocInfo else {
            throw CryptoError.containerOpeningFailed(
                CryptoErrorDetail(
                    message: "Cannot open container with invalid CDOC info"
                )
            )
        }

        let cryptoDataFiles = cdocInfo.dataFiles
        let recipients = cdocInfo.addressees

        var dataFiles: [URL] = []

        for dataFile in cryptoDataFiles {
            let fileUrl = URL(fileURLWithPath: dataFile.filePath ?? "").appending(path: dataFile.filename)

            dataFiles.append(fileUrl)
        }

        return try await create(
            containerFile: renamedContainerFile,
            dataFiles: dataFiles,
            recipients: recipients,
            isDecrypted: false,
            isEncrypted: true
        )
    }

    private static func create(
        containerFile: URL,
        dataFiles: [URL],
        recipients: [Addressee],
        isDecrypted: Bool,
        isEncrypted: Bool
    ) async throws -> CryptoContainerProtocol {

        return CryptoContainer(
            containerFile: containerFile,
            fileManager: Container.shared.fileManager(),
            containerUtil: Container.shared.containerUtil(),
            dataFiles: dataFiles,
            recipients: recipients,
            isDecrypted: isDecrypted,
            isEncrypted: isEncrypted,
        )
    }
}
