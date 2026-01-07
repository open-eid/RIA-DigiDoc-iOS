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
import FactoryKit
import LibdigidocLibObjC
import CommonsLib
import UtilsLib

public actor SignedContainer: SignedContainerProtocol, Loggable {

    private static let signedContainerLogTag: String = "SignedContainer"

    private var containerFile: URL?
    private let isExistingContainer: Bool
    private let container: ContainerWrapperProtocol
    private let timestamps: [SignatureWrapper]
    private let fileManager: FileManagerProtocol
    private let containerUtil: ContainerUtilProtocol

    public init(
        containerFile: URL? = nil,
        isExistingContainer: Bool = false,
        container: ContainerWrapperProtocol = Container.shared.containerWrapper(),
        timestamps: [SignatureWrapper] = [],
        fileManager: FileManagerProtocol,
        containerUtil: ContainerUtilProtocol
    ) {
        self.containerFile = containerFile
        self.isExistingContainer = isExistingContainer
        self.container = container
        self.timestamps = timestamps
        self.fileManager = fileManager
        self.containerUtil = containerUtil
    }

    public func getDataFiles() async -> [DataFileWrapper] {
        return await container.getDataFiles()
    }

    public func getSignatures() async -> [SignatureWrapper] {
        return await container.getSignatures()
    }

    public func getTimestamps() async -> [SignatureWrapper] {
        return timestamps
    }

    public func getContainerName() async -> String {
        return containerFile?.lastPathComponent ?? CommonsLib.Constants.Container.DefaultName
    }

    public func getContainerMimetype() async -> String {
        return await container.getMimetype()
    }

    public func getRawContainerFile() async -> URL? {
        return containerFile
    }

    public func isExistingContainer() async -> Bool {
        return isExistingContainer
    }

    public func isSigned() async -> Bool {
        return await !container.getSignatures().isEmpty
    }

    public func getSignaturesStatusCount() async -> [SignatureStatus: Int] {
        var counts: [SignatureStatus: Int] = [
            .valid: 0,
            .unknown: 0,
            .invalid: 0
        ]

        let signatures = await getSignatures()

        for signature in signatures {
            let status = signature.status
            counts[status, default: 0] += 1
        }

        return counts
    }

    public func isEmptyFileInContainer() async -> Bool {
        await getDataFiles().contains { dataFile in
            dataFile.fileSize == 0
        }
    }

    public func isCades() async -> Bool {
        let signatures = await getSignatures()

        return signatures.contains(where: { $0.format.lowercased().contains("cades") })
    }

    public func isXades() async -> Bool {
        let containerMimetype = await getContainerMimetype().lowercased()
        let signatures = await getSignatures()

        if containerMimetype.caseInsensitiveCompare(Constants.MimeType.Asics.lowercased()) == .orderedSame,
           signatures.contains(where: { $0.format.lowercased().contains("bes") }) {
            return true
        }

        return false
    }

    @discardableResult
    public func addDataFiles(_ dataFiles: [URL], to containerFile: URL) async throws -> SignedContainerProtocol {
        if dataFiles.isEmpty {
            throw DigiDocError.addingFilesToContainerFailed(
                ErrorDetail(
                    message: "SignedContainer - cannot add data files. No data files found",
                    code: 5
                )
            )
        }

        let updatedContainer = try await container.addDataFiles(containerFile: containerFile, dataFiles: dataFiles)

        return SignedContainer(
            containerFile: containerFile,
            isExistingContainer: true,
            container: updatedContainer,
            timestamps: timestamps,
            fileManager: fileManager,
            containerUtil: containerUtil
        )
    }

    @discardableResult
    public func renameContainer(to newName: String) async throws -> SignedContainerProtocol {

        let fileName = newName.isEmpty ? CommonsLib.Constants.Container.DefaultName : newName

        let sanitizedFileName = fileName.sanitized()
        let normalizedPath = URL(fileURLWithPath: sanitizedFileName).standardizedPathURL

        guard let currentURL = containerFile else {
            throw DigiDocError.containerRenamingFailed(
                ErrorDetail(
                    message: "Unable to rename container. Current URL is nil",
                    userInfo: ["fileName": containerFile?.lastPathComponent ?? ""]
                )
            )
        }

        let newFileName = normalizedPath.lastPathComponent
        guard !newFileName.isEmpty else {
            throw DigiDocError.containerRenamingFailed(
                ErrorDetail(
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

        try fileManager.moveItem(at: currentURL, to: uniqueFileURL)

        let container = try await ContainerWrapper(
            fileManager: fileManager
        ).open(containerFile: uniqueFileURL, isSivaConfirmed: true)

        return SignedContainer(
            containerFile: uniqueFileURL,
            isExistingContainer: true,
            container: container,
            fileManager: Container.shared.fileManager(),
            containerUtil: Container.shared.containerUtil()
        )
    }

    public func saveDataFile(dataFile: DataFileWrapper, to directory: URL?) async throws -> URL {
        guard let containerFileURL = containerFile else {
            throw DigiDocError.containerDataFileSavingFailed(
                ErrorDetail(
                    message: "Unable to save container. No container file found.",
                    userInfo: ["fileName": containerFile?.lastPathComponent ?? "N/A"]
                )
            )
        }
        return try await container.saveDataFile(containerFile: containerFileURL, dataFile: dataFile, to: directory)
    }

    public func getNestedTimestampedContainer() async throws -> SignedContainerProtocol? {
        let isCades = await isCades()
        let isXades = await isXades()

        guard await getContainerMimetype() == CommonsLib.Constants.MimeType.Asics &&
                !isCades && !isXades else { return nil }

        let dataFiles = await getDataFiles()
        guard dataFiles.count == 1, let dataFile = dataFiles.first else { return nil }

        guard let containerFile = containerFile else { return nil }

        let containerDataFilesDir = try containerUtil.getContainerDataFilesDir(containerFile: containerFile)

        let nestedTimestampedFile = try await saveDataFile(dataFile: dataFile, to: containerDataFilesDir)

        let nestedContainer = try await ContainerWrapper(
            fileManager: fileManager
        ).open(containerFile: nestedTimestampedFile, isSivaConfirmed: true)

        let timestamps = await container.getSignatures()

        return SignedContainer(
            containerFile: containerFile,
            isExistingContainer: true,
            container: nestedContainer,
            timestamps: timestamps,
            fileManager: fileManager,
            containerUtil: containerUtil
        )
    }

    @discardableResult
    public func removeSignature(index: Int, containerFile: URL) async throws -> SignedContainerProtocol {
        let containerWrapper = try await container.removeSignature(index: index, containerFile: containerFile)

        return SignedContainer(
            containerFile: containerFile,
            isExistingContainer: true,
            container: containerWrapper,
            timestamps: timestamps,
            fileManager: fileManager,
            containerUtil: containerUtil
        )
    }

    @discardableResult
    public func removeDataFile(index: Int, containerFile: URL) async throws -> SignedContainerProtocol {
        let containerWrapper = try await container.removeDataFile(index: index, containerFile: containerFile)

        return SignedContainer(
            containerFile: containerFile,
            isExistingContainer: true,
            container: containerWrapper,
            timestamps: timestamps,
            fileManager: fileManager,
            containerUtil: containerUtil
        )
    }

    public func prepareSignature(
        cert: Data,
        containerPath: URL,
        roleData: RoleData,
        userAgent: String
    ) async throws -> Data {
        return try await container
            .prepareSignature(
                cert: cert,
                containerPath: containerPath,
                roleData: roleData,
                userAgent: userAgent
            )
    }

    public func addSignature(signature: Data, containerFile: URL) async throws -> SignedContainerProtocol {
        let containerWrapper = try await container.addSignature(
            signature: signature,
            containerFile: containerFile
        )

        return SignedContainer(
            containerFile: containerFile,
            isExistingContainer: true,
            container: containerWrapper,
            timestamps: timestamps,
            fileManager: fileManager,
            containerUtil: containerUtil
        )
    }
}

extension SignedContainer {

    @MainActor
    public static func openOrCreate(
        dataFiles: [URL],
        containerUtil: ContainerUtilProtocol = Container.shared.containerUtil(),
        isSivaConfirmed: Bool
    ) async throws -> SignedContainerProtocol {
        logger().debug("Opening or creating container. Found \(dataFiles.count) datafile(s)")
        guard let firstFile = dataFiles.first else {
            logger().error("Unable to create or open container. First datafile is nil")
            throw DigiDocError.containerCreationFailed(
                ErrorDetail(
                    message: "Cannot create or open container. Datafiles are empty"
                )
            )
        }

        let isFirstDataFilePDF = await firstFile.isPDF() && firstFile.isSignedPDF()

        let isFirstDataFileContainer = await firstFile.isContainer() || isFirstDataFilePDF
        var containerFile: URL? = firstFile

        if (!isFirstDataFileContainer || (dataFiles.count) > 1) &&
            firstFile.pathExtension != CommonsLib.Constants.Extension.Default {
            let uniqueContainerFile = firstFile
                .deletingPathExtension()
                .appendingPathExtension(CommonsLib.Constants.Extension.Default)
            containerFile = containerUtil.getContainerFile(
                for: uniqueContainerFile,
                in: uniqueContainerFile.deletingLastPathComponent()
            )
        }

        guard let containerFile else {
            let error = isFirstDataFileContainer
            ? DigiDocError.containerOpeningFailed(
                ErrorDetail(
                    message: "Cannot open container. Container file is nil"))
            : DigiDocError.containerCreationFailed(
                ErrorDetail(
                    message: "Cannot create container. Container file is nil"
                )
            )
            throw error
        }

        if dataFiles.count == 1 && isFirstDataFileContainer {
            SignedContainer.logger().debug("Opening existing container")
            return try await open(file: containerFile, isSivaConfirmed: isSivaConfirmed)
        }

        SignedContainer.logger().debug("Creating a new container")
        return try await create(containerFile: containerFile, dataFiles: dataFiles)
    }

    private static func open(file: URL, isSivaConfirmed: Bool) async throws -> SignedContainerProtocol {
        let fileManager = Container.shared.fileManager()

        let signedContainersDirectory = try Directories.getCacheDirectory(
            subfolder: Constants.Folder.SignedContainerFolder,
            fileManager: fileManager
        )

        let isFileInTempSignedContainerDirectory = file.absoluteString.hasPrefix(
            signedContainersDirectory.appending(path: Constants.Folder.Temp, directoryHint: .isDirectory).absoluteString
        )

        let isFileInRecentDocuments = file.absoluteString.hasPrefix(
            signedContainersDirectory.absoluteString
        ) && !isFileInTempSignedContainerDirectory

        var renamedContainerFile = file

        if !isFileInRecentDocuments {
            renamedContainerFile = Container.shared.containerUtil().getContainerFile(
                for: file,
                in: isFileInRecentDocuments ? file.deletingLastPathComponent() :
                    file.deletingLastPathComponent().deletingLastPathComponent()
            )

            try fileManager.moveItem(at: file, to: renamedContainerFile)
        }

        let container = try await ContainerWrapper(
            fileManager: fileManager
        ).open(containerFile: renamedContainerFile, isSivaConfirmed: isSivaConfirmed)

        return SignedContainer(
            containerFile: renamedContainerFile,
            isExistingContainer: true,
            container: container,
            fileManager: Container.shared.fileManager(),
            containerUtil: Container.shared.containerUtil()
        )
    }

    private static func create(
        containerFile: URL,
        dataFiles: [URL]
    ) async throws -> SignedContainerProtocol {
        let fileManager = Container.shared.fileManager()
        let containerWrapper = ContainerWrapper(
            fileManager: fileManager
        )

        let renamedContainerFile = Container.shared.containerUtil().getContainerFile(
            for: containerFile,
            in: containerFile.deletingLastPathComponent().deletingLastPathComponent()
        )

        try await containerWrapper
            .create(
                file: renamedContainerFile,
                dataFiles: dataFiles.compactMap {
                    $0.resolvedPath
                }
            )

        let createdContainer = try await containerWrapper.open(
            containerFile: renamedContainerFile,
            isSivaConfirmed: true
        )

        let signedContainer = SignedContainer(
            containerFile: renamedContainerFile,
            isExistingContainer: false,
            container: createdContainer,
            fileManager: Container.shared.fileManager(),
            containerUtil: Container.shared.containerUtil()
        )

        SignedContainer.logger().debug("Container created. Removing \(dataFiles.count) saved data files")
        for (index, dataFile) in dataFiles.enumerated() {
            let containerName = await signedContainer.getContainerName()
            if await dataFile.isContainer() && containerName == dataFile.lastPathComponent {
                continue
            }

            SignedContainer.logger().debug(
                "Removing data file (\(index + 1) / \(dataFiles.count)): \(dataFile.lastPathComponent)"
            )
            if fileManager.fileExists(atPath: dataFile.resolvedPath) &&
                fileManager.isDeletableFile(atPath: dataFile.resolvedPath) {
                try fileManager.removeItem(at: dataFile)
                SignedContainer.logger().debug("Data file: '\(dataFile.lastPathComponent)' removed")
            }
        }

        return signedContainer
    }
}
