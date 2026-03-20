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
import LibdigidocLibSwift
import CommonsLib
import UtilsLib
import CryptoSwift

@Observable
@MainActor
class SigningViewModel: SigningViewModelProtocol, Loggable {

    var dataFiles: [DataFileWrapper] = []
    var signatures: [SignatureWrapper] = []
    var timestamps: [SignatureWrapper] = []
    var containerName: String = CommonsLib.Constants.Container.DefaultName
    var containerMimetype: String = "N/A"
    var containerURL: URL?
    var previewFile: URL?
    var selectedDataFile: URL?
    var isShowingContainerFileSaver = false
    var isShowingFileSaver = false
    var showSignatureRemoveButton = false
    var isTimestampedContainer = false
    var isCadesContainer = false
    var isXadesContainer = false
    var isLastDataFileRemoved = false
    var navigateToNestedCryptoContainerView = false
    private(set) var containerNotifications: [ContainerNotificationType] = []
    private(set) var errorMessage: ToastMessage?
    private(set) var successMessage: ToastMessage?

    private let sharedContainerViewModel: SharedContainerViewModelProtocol
    private let fileOpeningService: FileOpeningServiceProtocol
    private let mimeTypeCache: MimeTypeCacheProtocol
    private let mimeTypeDecoder: MimeTypeDecoderProtocol
    private let fileUtil: FileUtilProtocol
    private let fileManager: FileManagerProtocol
    private let fileInspector: FileInspectorProtocol
    private let sivaRepository: SivaRepositoryProtocol
    private let containerUtil: ContainerUtilProtocol

    private(set) var signedContainer: SignedContainerProtocol?

    init(
        sharedContainerViewModel: SharedContainerViewModelProtocol,
        fileOpeningService: FileOpeningServiceProtocol,
        mimeTypeCache: MimeTypeCacheProtocol,
        mimeTypeDecoder: MimeTypeDecoderProtocol,
        fileUtil: FileUtilProtocol,
        fileManager: FileManagerProtocol,
        fileInspector: FileInspectorProtocol,
        sivaRepository: SivaRepositoryProtocol,
        containerUtil: ContainerUtilProtocol
    ) {
        self.sharedContainerViewModel = sharedContainerViewModel
        self.fileOpeningService = fileOpeningService
        self.mimeTypeCache = mimeTypeCache
        self.mimeTypeDecoder = mimeTypeDecoder
        self.fileUtil = fileUtil
        self.fileManager = fileManager
        self.fileInspector = fileInspector
        self.sivaRepository = sivaRepository
        self.containerUtil = containerUtil
    }

    func loadContainerData(signedContainer: SignedContainerProtocol?) async {
        SigningViewModel.logger().info("Loading signed container data")
        sharedContainerViewModel.setIsSignatureAdded(false)
        let openedContainer = (signedContainer ?? sharedContainerViewModel.currentContainer())
            as? any SignedContainerProtocol
        guard let openedContainer else {
            SigningViewModel.logger().error("Cannot load signed container data. Signed container is nil.")
            return
        }

        self.signedContainer = openedContainer

        self.containerName = await openedContainer.getContainerName()
        self.dataFiles = await openedContainer.getDataFiles()
        self.signatures = await openedContainer.getSignatures()
        self.timestamps = await openedContainer.getTimestamps()
        self.containerMimetype = await openedContainer.getContainerMimetype()
        self.containerURL = await openedContainer.getRawContainerFile()
        self.isTimestampedContainer = await isTimestampedContainer()
        self.isCadesContainer = await openedContainer.isCades()
        self.isXadesContainer = await openedContainer.isXades()

        self.containerNotifications = await getContainerNotifications(container: openedContainer)

        SigningViewModel.logger().info("Signed container data loaded")
    }

    func getContainerNotifications(container: SignedContainerProtocol) async -> [ContainerNotificationType] {
        let signatureCounts = await container.getSignaturesStatusCount()

        let unknownSignaturesCount = signatureCounts[.unknown] ?? 0
        let invalidSignaturesCount = signatureCounts[.invalid] ?? 0

        let isEmptyFileInContainer = await container.isEmptyFileInContainer()
        let isUnsupportedContainer = await Constants.MimeType.Ddoc == container.getRawContainerFile()?.mimeType(
            fileUtil: fileUtil,
            mimeTypeDecoder: mimeTypeDecoder
        )

        return [
            isEmptyFileInContainer ? .emptyFile : nil,
            isUnsupportedContainer ? .unsupportedContainer : nil,
            isCadesContainer ? .cadesFile : nil,
            isXadesContainer ? .xadesFile : nil,
            unknownSignaturesCount > 0 ? .unknownSignatures(count: unknownSignaturesCount) : nil,
            invalidSignaturesCount > 0 ? .invalidSignatures(count: invalidSignaturesCount) : nil
        ].compactMap { $0 }
    }

    func isSigned() -> Bool {
        return !signatures.isEmpty
    }

    func createCopyOfContainerForSaving(containerURL: URL?) -> URL? {
        guard let containerLocation = containerURL else {
            SigningViewModel.logger().error("Unable to get signed container to create copy for saving")
            return nil
        }

        do {
            let savedFilesDirectory = try Directories.getCacheDirectory(
                subfolders: [Constants.Folder.SavedFiles, Constants.Folder.Temp],
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
                    SigningViewModel.logger().error("Unable to remove existing file: \(error.localizedDescription)")
                    return nil
                }
            }

            do {
                try fileManager.copyItem(at: containerLocation, to: tempSavedFileLocation)
            } catch {
                SigningViewModel.logger().error("Unable to copy file: \(error.localizedDescription)")
                return nil
            }

            return tempSavedFileLocation
        } catch {
            SigningViewModel.logger().error("Unable to get cache directory: \(error.localizedDescription)")
            return nil
        }
    }

    func removeSavedFilesDirectory(savedFilesDirectory: URL? = nil) {
        SigningViewModel.logger().info("Removing 'Saved Files' directory (SigningViewModel)")
        fileUtil.removeSavedFilesDirectory(savedFilesDirectory: savedFilesDirectory)
    }

    public func addDataFiles(_ files: [URL], to container: URL) async {
        do {
            try validateFiles(files)
        } catch {
            handleFileValidationError(error)
            return
        }

        do {
            let updatedContainer = try await signedContainer?.addDataFiles(files, to: container)
            SigningViewModel.logger().info("Added data files to container")
            successMessage = ToastMessage(
                key: files.count == 1 ? "File successfully added" : "Files successfully added",
                args: []
            )
            await loadContainerData(signedContainer: updatedContainer)
        } catch {
            await handleAddFilesError(error, container: container)
        }
    }

    public func isSignatureAdded() -> Bool {
        sharedContainerViewModel.getIsSignatureAdded()
    }

    public func removeLastOpenedXattr(from url: URL) {
        do {
            try url.removeLastOpenedXattr()
        } catch {
            SigningViewModel.logger().error("Unable to remove last opened xattr: \(error)")
        }
    }

    private func validateFiles(_ files: [URL]) throws {
        guard let firstFile = files.first else {
            throw FileOpeningError.noDataFiles
        }

        // Show specific error message when unable to validate a single file
        if files.count == 1 {
            if dataFiles.contains(where: { $0.fileName == firstFile.lastPathComponent }) {
                throw DigiDocError.addingFilesToContainerFailed(
                    ErrorDetail(
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
        case let digiDocError as DigiDocError:
            switch digiDocError {
            case .addingFilesToContainerFailed(let detail):
                let fileName = detail.userInfo["fileName"] as? String ?? ""
                errorMessage = ToastMessage(key: detail.message, args: [fileName])
            default:
                errorMessage = ToastMessage(key: "General error", args: [])
            }

        case let fileError as FileOpeningError:
            switch fileError {
            case .invalidFileSize:
                errorMessage = ToastMessage(key: "Invalid file size", args: [])
            case .noDataFiles:
                errorMessage = ToastMessage(key: "Could not load selected files", args: [])
            default:
                errorMessage = ToastMessage(key: "General error", args: [])
            }

        default:
            errorMessage = ToastMessage(key: "General error", args: [])
        }
    }

    private func handleAddFilesError(_ error: Error, container: URL) async {
        SigningViewModel.logger().error("Unable to add data files to container: \(error.localizedDescription)")

        var totalFileCount = 0
        var failedFileCount = 0
        var duplicateFileCount = 0

        guard let digiDocError = error as? DigiDocError else {
            errorMessage = ToastMessage(key: "General error", args: [])
            return
        }

        switch digiDocError {
        case .addingFilesToContainerFailed(let errorDetail):
            totalFileCount = Int(errorDetail.userInfo["totalFileCount"] as? Int ?? 0)
            failedFileCount = Int(errorDetail.userInfo["failedFileCount"] as? Int ?? 0)
            duplicateFileCount = Int(errorDetail.userInfo["duplicateFileCount"] as? Int ?? 0)

            if duplicateFileCount > 1 {
                errorMessage = ToastMessage(key: "Multiple documents already exist", args: [String(duplicateFileCount)])
            } else if duplicateFileCount == 1 {
                if let fileName = errorDetail.userInfo["fileName"] as? String {
                    errorMessage = ToastMessage(key: "Document already exists", args: [fileName])
                } else {
                    errorMessage = ToastMessage(key: errorDetail.message, args: [String(failedFileCount)])
                }
            } else {
                errorMessage = ToastMessage(key: errorDetail.message, args: [String(failedFileCount)])
            }

        default:
            errorMessage = ToastMessage(key: "General error", args: [])
        }

        // Update container when at least one file has been added to container
        guard totalFileCount > failedFileCount else { return }

        await refreshContainer(with: container)

        let successfulFilesCount = totalFileCount - failedFileCount

        successMessage = successfulFilesCount == 1 ?
        ToastMessage(key: "Single document added") :
        ToastMessage(
            key: "Multiple documents added",
            args: [String(successfulFilesCount)]
        )
    }

    private func refreshContainer(with container: URL) async {
        do {
            let updatedContainer = try await SignedContainer.openOrCreate(
                dataFiles: [container],
                isSivaConfirmed: true
            )
            await loadContainerData(signedContainer: updatedContainer)
        } catch {
            errorMessage = ToastMessage(key: "General error", args: [])
        }
    }

    @discardableResult
    public func renameContainer(to newName: String) async -> URL? {
        do {
            let renamedContainer = try await signedContainer?.renameContainer(to: newName)
            sharedContainerViewModel.removeLastContainer()
            sharedContainerViewModel.setSignedContainer(renamedContainer)
            await loadContainerData(signedContainer: renamedContainer)
            return await renamedContainer?.getRawContainerFile()
        } catch {
            SigningViewModel.logger().error("Unable to rename container: \(error)")
            if let digiDocError = error as? DigiDocError {
                switch digiDocError {
                case .containerRenamingFailed(let errorDetail),
                        .containerSavingFailed(let errorDetail):
                    errorMessage = ToastMessage(
                        key: "Failed to rename file",
                        args: [errorDetail.userInfo["fileName"] as? String ?? ""]
                    )
                default:
                    errorMessage = ToastMessage(key: "General error", args: [])
                }
            } else {
                errorMessage = ToastMessage(key: "General error", args: [])
            }
            return nil
        }
    }

    func getDataFileURL(_ dataFile: DataFileWrapper) async -> Result<URL, Error> {
        do {
            let dataFileURL = try await signedContainer?.saveDataFile(dataFile: dataFile, to: nil)

            guard fileUtil.fileExists(fileLocation: dataFileURL), let fileURL = dataFileURL else {
                throw DigiDocError.containerDataFileSavingFailed(
                    ErrorDetail(
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

    func handleFileOpening(dataFile: DataFileWrapper, isSivaConfirmed: Bool) async {
        let result = await getDataFileURL(dataFile)

        switch result {
        case .success(let fileURL):
            let mimeType = await mimeTypeCache.getMimeType(fileUrl: fileURL)

            if mimeType == Constants.MimeType.Ddoc && !isSivaConfirmed {
                return
            }

            let isContainer = await fileURL.isContainer()
            let isCryptoContainer = await fileURL.isCryptoContainer()

            if isContainer {
                do {
                    await MainActor.run {
                        navigateToNestedCryptoContainerView = false
                    }
                    try await openNestedContainer(fileURL: fileURL, isSivaConfirmed: isSivaConfirmed)
                } catch {
                    SigningViewModel.logger().error("Failed to open nested container: \(error)")
                    errorMessage = ToastMessage(key: "Failed to open container", args: [dataFile.fileName])
                    if error.localizedDescription.contains("Online validation disabled") {
                        SigningViewModel.logger().error(
                            "Unable to open container '\([dataFile.fileName])'. Sending to SiVa not allowed."
                        )
                        errorMessage = nil
                    } else {
                        SigningViewModel.logger().error("Failed to open nested container: \(error)")
                        errorMessage = ToastMessage(key: "Failed to open container", args: [dataFile.fileName])
                    }
                }
            } else if isCryptoContainer {
                do {
                    try await openNestedCryptoContainer(fileUrl: fileURL)
                    await MainActor.run {
                        navigateToNestedCryptoContainerView = true
                    }
                } catch {
                    SigningViewModel.logger().error(
                        "Failed to open nested crypto container: \(String(reflecting: error))"
                    )
                    errorMessage = ToastMessage(key: "Failed to open container", args: [dataFile.fileName])
                    return
                }
            } else {
                previewFile = fileURL
            }
        case .failure:
            errorMessage = ToastMessage(key: "Failed to open file", args: [dataFile.fileName])
        }
    }

    func handleSaveFile(dataFile: DataFileWrapper) async {
        let result = await getDataFileURL(dataFile)

        switch result {
        case .success(let fileURL):
            selectedDataFile = fileURL
            isShowingFileSaver = true

        case .failure:
            errorMessage = ToastMessage(key: "Failed to save file", args: [dataFile.fileName])
            isShowingFileSaver = false
        }
    }

    func isSivaConfirmationNeeded(dataFile: DataFileWrapper) async -> Bool {
        let result = await getDataFileURL(dataFile)

        switch result {
        case .success(let fileURL):
            return await sivaRepository.isSivaConfirmationNeeded(files: [fileURL])
        case .failure(let error):
            SigningViewModel.logger().error(
                "Unable to get data file '\(dataFile.fileName)' URL: \(String(reflecting: error))"
            )
            return false
        }
    }

    func isNestedContainer() -> Bool {
        return sharedContainerViewModel.isNestedContainer(
            sharedContainerViewModel.currentContainer()
        )
    }

    func handleBackButton() async -> Bool {
        await MainActor.run {
            navigateToNestedCryptoContainerView = false
        }
        if sharedContainerViewModel.containers().count > 1 {
            sharedContainerViewModel.removeLastContainer()
            let currentContainer = sharedContainerViewModel.currentContainer() as? any SignedContainerProtocol
            sharedContainerViewModel.setSignedContainer(currentContainer)
            if currentContainer == nil { return true }
            await loadContainerData(signedContainer: currentContainer)
            return false
        } else {
            sharedContainerViewModel.clearContainers()
            return true
        }
    }

    func isSignButtonShown(
        signedContainer: SignedContainerProtocol?,
        isNestedContainer: Bool
    ) async -> Bool {
        let mimetype = await signedContainer?.getContainerMimetype() ?? Constants.MimeType.Container
        let name = await signedContainer?.getContainerName() ?? Constants.Container.DefaultName
        let isEmptyFileInContainer = await signedContainer?.isEmptyFileInContainer() ?? false

        return signedContainer != nil &&
        (!Constants.MimeType.UnsignableContainers.contains(mimetype)) &&
        (!Constants.Extension.UnsignableContainerExtensions.contains((name as NSString).pathExtension)) &&
        !isNestedContainer && !isEmptyFileInContainer && !isCadesContainer && !isXadesContainer
    }

    func isEncryptButtonShown(
        signedContainer: SignedContainerProtocol?,
        isNestedContainer: Bool,
    ) async -> Bool {
        guard let container = signedContainer else { return false }
        let isExistingContainer = await container.isExistingContainer()
        return (isExistingContainer || isSigned()) && !isNestedContainer
    }

    func isSignatureRemoveButtonShown() -> Bool {
        return !isNestedContainer() && !isCadesContainer && !isXadesContainer
    }

    func isTimestampedContainer() async -> Bool {
        guard let container = signedContainer, await !container.isXades() else {
            return false
        }

        return await sivaRepository.isTimestampedContainer(signedContainer: container)
    }

    func removeSignature(_ signature: SignatureWrapper) async {
        guard let container = signedContainer, let containerFile = containerURL else {
            SigningViewModel.logger().error(
                "Unable to remove signature from container. SignedContainer or containerURL is nil"
            )
            errorMessage = ToastMessage(key: "Failed to remove signature from container", args: [])
            return
        }

        do {
            let container = try await container.removeSignature(index: signature.pos, containerFile: containerFile)
            await loadContainerData(signedContainer: container)
        } catch {
            SigningViewModel.logger().error("Unable to remove signature from container. \(error)")
            errorMessage = ToastMessage(key: "Failed to remove signature from container", args: [])
            return
        }
    }

    func removeDataFile(_ dataFile: DataFileWrapper) async {
        guard let container = signedContainer, let containerFile = containerURL else {
            SigningViewModel.logger().error(
                "Unable to remove file from container. SignedContainer or containerURL is nil"
            )
            errorMessage = ToastMessage(
                key: "Failed to remove file from container",
                args: [dataFile.fileName]
            )
            return
        }

        guard let index = dataFiles.firstIndex(where: { $0.fileId == dataFile.fileId }) else {
            SigningViewModel.logger().error(
                "Unable to remove file from container. File not found in container"
            )
            errorMessage = ToastMessage(key: "Failed to remove file from container", args: [dataFile.fileName])
            return
        }

        do {
            if dataFiles.count == 1 {
                try fileManager.removeItem(at: containerFile)
                isLastDataFileRemoved = true
                return
            }

            let container = try await container.removeDataFile(index: index, containerFile: containerFile)
            await loadContainerData(signedContainer: container)
            return
        } catch {
            SigningViewModel.logger().error("Unable to remove file from container. \(error)")
            errorMessage = ToastMessage(
                key: "Failed to remove file from container",
                args: [dataFile.fileName]
            )
            return
        }
    }

    func resetErrorMessage() {
        errorMessage = nil
    }

    func resetSuccessMessage() {
        successMessage = nil
    }

    func convertToCryptoContainer() async -> Bool {
        do {
            guard let container = signedContainer else {
                throw URLError(.fileDoesNotExist)
            }

            var dataFileURLs: [URL] = []

            if await container.getSignatures().isEmpty {
                let dataFilesDir = try containerUtil
                    .getContainerDataFilesDir(containerFile: containerURL)

                for dataFile in dataFiles {
                    let url = try await container
                        .saveDataFile(dataFile: dataFile, to: dataFilesDir)
                    dataFileURLs.append(url)
                }
            } else {
                guard let containerURL else {
                    throw URLError(.fileDoesNotExist)
                }
                dataFileURLs = [containerURL]
            }

            let cryptoContainer = try await
                CryptoContainer.openOrCreate(dataFiles: dataFileURLs)

            sharedContainerViewModel.setSignedContainer(nil)
            sharedContainerViewModel.clearContainers()
            sharedContainerViewModel.setAddedFilesCount(addedFiles: dataFileURLs.count)
            sharedContainerViewModel.setCryptoContainer(cryptoContainer)

            return true

        } catch {
            SigningViewModel.logger()
                .error("Unable to convert SignedContainer to CryptoContainer: \(error)")
            return false
        }
    }

    private func openNestedContainer(fileURL: URL, isSivaConfirmed: Bool) async throws {
        let container = try await fileOpeningService.openOrCreateContainer(
            dataFiles: [fileURL],
            isSivaConfirmed: isSivaConfirmed
        )

        let isXades = await container.isXades()
        let isTimestampedContainer = await sivaRepository.isTimestampedContainer(signedContainer: container)
        if isSivaConfirmed && isTimestampedContainer && !isXades {
            let nestedTimestampedContainer = try await sivaRepository
                .getTimestampedContainer(parentContainer: container)
            sharedContainerViewModel.setSignedContainer(nestedTimestampedContainer)
            await loadContainerData(signedContainer: nestedTimestampedContainer)
        } else {
            sharedContainerViewModel.setSignedContainer(container)
            await loadContainerData(signedContainer: container)
        }
    }

    private func openNestedCryptoContainer(fileUrl: URL) async throws {
        let container = try await fileOpeningService.openOrCreateCryptoContainer(
            dataFiles: [fileUrl]
        )

        sharedContainerViewModel.setCryptoContainer(container)
    }
}
