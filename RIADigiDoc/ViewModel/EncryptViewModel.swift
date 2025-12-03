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
import OSLog
import CryptoSwift
import CryptoObjCWrapper
import CommonsLib
import UtilsLib

@Observable
@MainActor
class EncryptViewModel: EncryptViewModelProtocol {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "EncryptViewModel")

    var dataFiles: [URL] = []
    var recipients: [Addressee] = []
    var containerName: String = CommonsLib.Constants.Container.DefaultName
    var containerMimetype: String = "N/A"
    var containerURL: URL?
    var previewFile: URL?
    var selectedDataFile: URL?
    var isShowingContainerFileSaver = false
    var isShowingFileSaver = false
    var showRecipientRemoveButton = false
    var isLastDataFileRemoved = false
    private(set) var errorMessage: ErrorMessage?

    private let sharedContainerViewModel: SharedContainerViewModelProtocol
    private let fileOpeningService: FileOpeningServiceProtocol
    private let mimeTypeCache: MimeTypeCacheProtocol
    private let mimeTypeDecoder: MimeTypeDecoderProtocol
    private let fileUtil: FileUtilProtocol
    private let fileManager: FileManagerProtocol
    private let fileInspector: FileInspectorProtocol
    private let sivaRepository: SivaRepositoryProtocol

    private(set) var cryptoContainer: CryptoContainerProtocol?

    private(set) var isContainerWithoutRecipients = false
    private(set) var isContainerEncrypted = false
    private(set) var isContainerDecrypted = false
    private(set) var isContainerUnlocked = false
    private(set) var isEncryptButtonShown = false
    private(set) var isDecryptButtonShown = false
    private(set) var isSignButtonShown = false
    private(set) var isShareButtonShown = false
    private(set) var isEditButtonShown = false
    private(set) var shouldShowDatafiles = false

    init(
        sharedContainerViewModel: SharedContainerViewModelProtocol,
        fileOpeningService: FileOpeningServiceProtocol,
        mimeTypeCache: MimeTypeCacheProtocol,
        mimeTypeDecoder: MimeTypeDecoderProtocol,
        fileUtil: FileUtilProtocol,
        fileManager: FileManagerProtocol,
        fileInspector: FileInspectorProtocol,
        sivaRepository: SivaRepositoryProtocol
    ) {
        self.sharedContainerViewModel = sharedContainerViewModel
        self.fileOpeningService = fileOpeningService
        self.mimeTypeCache = mimeTypeCache
        self.mimeTypeDecoder = mimeTypeDecoder
        self.fileUtil = fileUtil
        self.fileManager = fileManager
        self.fileInspector = fileInspector
        self.sivaRepository = sivaRepository
    }

    func loadContainerData(cryptoContainer: CryptoContainerProtocol?) async {
        EncryptViewModel.logger.debug("Loading container data")
        let openedContainer = (cryptoContainer ?? sharedContainerViewModel.currentContainer())
            as? any CryptoContainerProtocol
        guard let openedContainer else {
            EncryptViewModel.logger.error("Cannot load container data. Crypto container is nil.")
            return
        }

        self.cryptoContainer = openedContainer

        self.containerName = await openedContainer.getContainerName()
        self.dataFiles = await openedContainer.getDataFiles()
        self.recipients = await openedContainer.getRecipients()
        self.containerMimetype = await openedContainer.getContainerMimetype()
        self.containerURL = await openedContainer.getRawContainerFile()

        EncryptViewModel.logger.debug("Container data loaded")
    }

    func createCopyOfContainerForSaving(containerURL: URL?) -> URL? {
        guard let containerLocation = containerURL else {
            EncryptViewModel.logger.error("Unable to get container to create copy for saving")
            return nil
        }

        do {
            let savedFilesDirectory = try Directories.getCacheDirectory(
                subfolder: CommonsLib.Constants.Folder.SavedFiles,
                fileManager: fileManager
            )

            let filename = containerLocation.lastPathComponent.sanitized().isEmpty
                ? CommonsLib.Constants.Container.DefaultName
                : containerLocation.lastPathComponent.sanitized()

            let tempSavedFileLocation = savedFilesDirectory.appending(path: filename)

            if fileManager.fileExists(atPath: tempSavedFileLocation.resolvedPath) {
                do {
                    try fileManager.removeItem(at: tempSavedFileLocation)
                } catch {
                    EncryptViewModel.logger.error("Unable to remove existing file: \(error.localizedDescription)")
                    return nil
                }
            }

            do {
                try fileManager.copyItem(at: containerLocation, to: tempSavedFileLocation)
            } catch {
                EncryptViewModel.logger.error("Unable to copy file: \(error.localizedDescription)")
                return nil
            }

            return tempSavedFileLocation
        } catch {
            EncryptViewModel.logger.error("Unable to get cache directory: \(error.localizedDescription)")
            return nil
        }
    }

    func removeSavedFilesDirectory(savedFilesDirectory: URL? = nil) {
        fileUtil.removeSavedFilesDirectory(savedFilesDirectory: savedFilesDirectory)
    }

    public func addDataFiles(_ files: [URL]) async {
        do {
            try validateFiles(files)
        } catch {
            handleFileValidationError(error)
            return
        }

        await cryptoContainer?.addDataFiles(files)
        EncryptViewModel.logger.debug("Added data files to container")
        errorMessage = ErrorMessage(
            key: files.count == 1 ? "File successfully added" : "Files successfully added", 
            args: []
        )
        await loadContainerData(cryptoContainer: cryptoContainer)
    }

    private func validateFiles(_ files: [URL]) throws {
        guard let firstFile = files.first else {
            throw FileOpeningError.noDataFiles
        }

        // Show specific error message when unable to validate a single file
        if files.count == 1 {
            if dataFiles.contains(where: { $0.lastPathComponent == firstFile.lastPathComponent }) {
                throw CryptoError.addingFilesToContainerFailed(
                    CryptoErrorDetail(
                        message: "Document already exists",
                        userInfo: ["fileName": firstFile.lastPathComponent]
                    )
                )
            }

            if try fileInspector.fileSize(for: firstFile) == 0 {
                throw FileOpeningError.invalidFileSize
            }
        }
    }

    private func handleFileValidationError(_ error: Error) {
        switch error {
        case let cryptoError as CryptoError:
            switch cryptoError {
            case .addingFilesToContainerFailed(let detail):
                let fileName = detail.userInfo["fileName"] ?? ""
                errorMessage = ErrorMessage(
                    key: detail.message, 
                    args: [fileName]
                )
            default:
                errorMessage = ErrorMessage(
                    key: "General error", 
                    args: []
                )
            }

        case let fileError as FileOpeningError:
            switch fileError {
            case .invalidFileSize:
                errorMessage = ErrorMessage(
                    key: "Invalid file size", 
                    args: []
                )
            case .noDataFiles:
                errorMessage = ErrorMessage(
                    key: "Could not load selected files", 
                    args: []
                )
            default:
                errorMessage = ErrorMessage(
                    key: "General error", 
                    args: []
                )
            }

        default:
            errorMessage = ErrorMessage(
                key: "General error", 
                args: []
            )
        }
    }

    @discardableResult
    public func renameContainer(to newName: String) async -> URL? {
        do {
            return try await cryptoContainer?.renameContainer(to: newName)
        } catch {
            EncryptViewModel.logger.error("Unable to rename container: \(error)")
            if let cryptoError = error as? CryptoError {
                switch cryptoError {
                case .containerRenamingFailed(let errorDetail),
                        .containerSavingFailed(let errorDetail):
                    errorMessage = ErrorMessage(
                        key: "Failed to rename file",
                        args: [errorDetail.userInfo["fileName"] ?? ""]
                    )
                default:
                    errorMessage = ErrorMessage(key: "General error", args: [])
                }
            } else {
                errorMessage = ErrorMessage(key: "General error", args: [])
            }
            return nil
        }
    }

    func getDataFileURL(_ dataFile: URL) async -> Result<URL, Error> {
        do {
            let dataFileURL = try await cryptoContainer?.saveDataFile(dataFile: dataFile, to: nil)

            guard fileUtil.fileExists(fileLocation: dataFileURL), let fileURL = dataFileURL else {
                throw CryptoError.containerDataFileSavingFailed(
                    CryptoErrorDetail(
                        message: "Unable to save datafile",
                        code: 0,
                        userInfo: ["fileName": dataFileURL?.lastPathComponent ?? ""]
                    )
                )
            }

            return .success(fileURL)
        } catch {
            return .failure(error)
        }
    }

    func handleFileOpening(dataFile: URL, isSivaConfirmed: Bool) async {
        let result = await getDataFileURL(dataFile)

        switch result {
        case .success(let fileURL):
            let mimeType = await mimeTypeCache.getMimeType(fileUrl: fileURL)

            if mimeType == Constants.MimeType.Ddoc && !isSivaConfirmed {
                return
            }

            if Constants.Extension.CryptoContainers.contains(fileURL.pathExtension) {
                do {
                    try await openNestedContainer(fileURL: fileURL)
                    // TODO: Open signed container files
                } catch {
                    EncryptViewModel.logger.error("Failed to open nested container: \(error)")
                    errorMessage = ErrorMessage(key: "Failed to open container", args: [dataFile.lastPathComponent])
                }
            } else {
                previewFile = fileURL
            }
        case .failure:
            errorMessage = ErrorMessage(key: "Failed to open file", args: [dataFile.lastPathComponent])
        }
    }

    func handleSaveFile(dataFile: URL) async {
        let result = await getDataFileURL(dataFile)

        switch result {
        case .success(let fileURL):
            selectedDataFile = fileURL
            isShowingFileSaver = true

        case .failure:
            errorMessage = ErrorMessage(key: "Failed to save file", args: [dataFile.lastPathComponent])
            isShowingFileSaver = false
        }
    }

    func isSivaConfirmationNeeded(dataFile: URL) async -> Bool {
        let result = await getDataFileURL(dataFile)

        switch result {
        case .success(let fileURL):
            return await sivaRepository.isSivaConfirmationNeeded(files: [fileURL])
        case .failure:
            errorMessage = ErrorMessage(key: "Failed to open container", args: [dataFile.lastPathComponent])
            return false
        }
    }

    func isEncryptedContainer(cryptoContainer: CryptoContainerProtocol?) async -> Bool {
        guard let container = cryptoContainer else {
            return false
        }

        return await container.isEncrypted()
    }

    func isDecryptedContainer(cryptoContainer: CryptoContainerProtocol?) async -> Bool {
        guard let container = cryptoContainer else {
            return false
        }

        return await container.isDecrypted()
    }

    func isContainerWithoutRecipients(cryptoContainer: CryptoContainerProtocol?) async -> Bool {
        guard let container = cryptoContainer else {
            return false
        }

        return await container.getRecipients().isEmpty
    }

    func isNestedContainer() -> Bool {
        return sharedContainerViewModel.isNestedContainer(
            sharedContainerViewModel.currentContainer()
        )
    }

    func handleBackButton() async -> Bool {
        if sharedContainerViewModel.containers().count > 1 {
            sharedContainerViewModel.removeLastContainer()
            let currentContainer = sharedContainerViewModel.currentContainer() as? any CryptoContainerProtocol
            sharedContainerViewModel.setCryptoContainer(currentContainer)
            await loadContainerData(cryptoContainer: currentContainer)
            return false
        } else {
            sharedContainerViewModel.clearContainers()
            return true
        }
    }

    func isDataFilesInContainer(
        cryptoContainer: CryptoContainerProtocol?,
    ) async -> Bool {
        guard let container = cryptoContainer else {
            return false
        }

        return await !container.getDataFiles().isEmpty
    }

    func isCDOC1Container(
        cryptoContainer: CryptoContainerProtocol?,
    ) async -> Bool {
        return await cryptoContainer?.getRawContainerFile()?.pathExtension == Constants.Extension.Cdoc
    }

    func shouldShowDataFiles(
        cryptoContainer: CryptoContainerProtocol?,
    ) async -> Bool {
        let isCDOC1Container = await isCDOC1Container(cryptoContainer: cryptoContainer)
        let isEncryptedContainer = await isEncryptedContainer(cryptoContainer: cryptoContainer)
        let isDataFilesInContainer = await isDataFilesInContainer(cryptoContainer: cryptoContainer)
        return ((isEncryptedContainer && isCDOC1Container) || !isEncryptedContainer) && isDataFilesInContainer
    }

    func isInitialCryptoContainer(
        cryptoContainer: CryptoContainerProtocol?,
        isNestedContainer: Bool
    ) async -> Bool {
        let isContainerWithoutRecipients = await isContainerWithoutRecipients(cryptoContainer: cryptoContainer)
        let isEncryptedContainer = await isEncryptedContainer(cryptoContainer: cryptoContainer)
        let isDecryptedContainer = await isDecryptedContainer(cryptoContainer: cryptoContainer)
        return isContainerWithoutRecipients && !isEncryptedContainer && !isDecryptedContainer &&
            !isNestedContainer
    }

    func isUnlockedContainer(
        cryptoContainer: CryptoContainerProtocol?,
    ) async -> Bool {
        let isEncryptedContainer = await isEncryptedContainer(cryptoContainer: cryptoContainer)
        let isContainerWithoutRecipients = await isContainerWithoutRecipients(cryptoContainer: cryptoContainer)
        return !isEncryptedContainer && !isContainerWithoutRecipients
    }

    func isEditButtonShown(
        cryptoContainer: CryptoContainerProtocol?,
        isNestedContainer: Bool
    ) async -> Bool {
        let isEncryptedContainer = await isEncryptedContainer(cryptoContainer: cryptoContainer)
        let isDecryptedContainer = await isDecryptedContainer(cryptoContainer: cryptoContainer)
        return !isEncryptedContainer && !isDecryptedContainer && !isNestedContainer
    }

    func isSignButtonShown(
        cryptoContainer: CryptoContainerProtocol?,
        isNestedContainer: Bool
    ) async -> Bool {
        let isEncryptedContainer = await isEncryptedContainer(cryptoContainer: cryptoContainer)
        return isEncryptedContainer && !isNestedContainer
    }

    func isShareButtonShown(
        cryptoContainer: CryptoContainerProtocol?
    ) async -> Bool {
        let isEncryptedContainer = await isEncryptedContainer(cryptoContainer: cryptoContainer)
        let isDecryptedContainer = await isDecryptedContainer(cryptoContainer: cryptoContainer)
        return isEncryptedContainer && isDecryptedContainer
    }

    func isDecryptButtonShown(
        cryptoContainer: CryptoContainerProtocol?,
        isNestedContainer: Bool
    ) async -> Bool {
        return await isEncryptedContainer(cryptoContainer: cryptoContainer) && !isNestedContainer
    }

    func isEncryptButtonShown(
        cryptoContainer: CryptoContainerProtocol?,
        isNestedContainer: Bool
    ) async -> Bool {
        if await isDecryptedContainer(cryptoContainer: cryptoContainer) || isNestedContainer {
            return false
        }

        let isContainerWithoutRecipients = await !isContainerWithoutRecipients(cryptoContainer: cryptoContainer)

        return await (!isEncryptedContainer(cryptoContainer: cryptoContainer) && isContainerWithoutRecipients)
    }

    func isRecipientRemoveButtonShown() -> Bool {
        return isContainerDecrypted && isContainerUnlocked
    }

    func removeRecipient(_ recipient: Addressee) async {
        guard let container = cryptoContainer else {
            EncryptViewModel.logger.error(
                "Unable to remove signature from container. CryptoContainer or containerURL is nil"
            )
            errorMessage = ErrorMessage(
                key: "Failed to remove recipient from container", 
                args: []
            )
            return
        }

        do {
            try await container.removeRecipient(recipient)
            await loadContainerData(cryptoContainer: container)
        } catch {
            EncryptViewModel.logger.error("Unable to remove signature from container. \(error)")
            errorMessage = ErrorMessage(
                key: "Failed to remove signature from container", 
                args: []
            )
            return
        }
    }

    func removeDataFile(_ dataFile: URL) async {
        guard let container = cryptoContainer else {
            EncryptViewModel.logger.error(
                "Unable to remove file from container. CryptoContainer or containerURL is nil"
            )
            errorMessage = ErrorMessage(
                key: "Failed to remove file from container",
                args: [dataFile.lastPathComponent]
            )
            return
        }

        do {
            if dataFiles.count == 1 {
                isLastDataFileRemoved = true
                return
            }

            try await container.removeDataFile(dataFile)
            await loadContainerData(cryptoContainer: container)
            return
        } catch {
            EncryptViewModel.logger.error("Unable to remove file from container. \(error)")
            errorMessage = ErrorMessage(
                key: "Failed to remove file from container",
                args: [dataFile.lastPathComponent]
            )
            return
        }
    }

    func updateAsyncProperties() async {
        let isContainerWithoutRecipients = await isContainerWithoutRecipients(cryptoContainer: cryptoContainer)
        let isContainerEncrypted = await isEncryptedContainer(cryptoContainer: cryptoContainer)
        let isContainerDecrypted = await isDecryptedContainer(cryptoContainer: cryptoContainer)
        let isContainerUnlocked = await isUnlockedContainer(cryptoContainer: cryptoContainer)
        let isEncryptButtonShown = await isEncryptButtonShown(
            cryptoContainer: cryptoContainer,
            isNestedContainer: isNestedContainer()
        )
        let isDecryptButtonShown = await isDecryptButtonShown(
            cryptoContainer: cryptoContainer,
            isNestedContainer: isNestedContainer()
        )
        let isSignButtonShown = await isSignButtonShown(
            cryptoContainer: cryptoContainer,
            isNestedContainer: isNestedContainer()
        )
        let isShareButtonShown = await isShareButtonShown(cryptoContainer: cryptoContainer)
        let isEditButtonShown = await isEditButtonShown(
            cryptoContainer: cryptoContainer,
            isNestedContainer: isNestedContainer()
        )
        let shouldShowDatafiles = await shouldShowDataFiles(cryptoContainer: cryptoContainer)

        await MainActor.run {
            self.isContainerWithoutRecipients = isContainerWithoutRecipients
            self.isContainerEncrypted = isContainerEncrypted
            self.isContainerDecrypted = isContainerDecrypted
            self.isContainerUnlocked = isContainerUnlocked
            self.isEncryptButtonShown = isEncryptButtonShown
            self.isDecryptButtonShown = isDecryptButtonShown
            self.isSignButtonShown = isSignButtonShown
            self.isShareButtonShown = isShareButtonShown
            self.isEditButtonShown = isEditButtonShown
            self.shouldShowDatafiles = shouldShowDatafiles
        }
    }

    private func openNestedContainer(fileURL: URL) async throws {
        if Constants.Extension.CryptoContainers.contains(fileURL.pathExtension) {
            let container = try await fileOpeningService
                .openOrCreateCryptoContainer(dataFiles: [fileURL])
            await loadContainerData(cryptoContainer: container)
        } else {
            // TODO: Load nested signed containers
        }
    }
}
