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
import LibdigidocLibSwift
import CommonsLib
import UtilsLib

@MainActor
class SigningViewModel: SigningViewModelProtocol, ObservableObject {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "SigningViewModel")

    @Published var dataFiles: [DataFileWrapper] = []
    @Published var signatures: [SignatureWrapper] = []
    @Published var timestamps: [SignatureWrapper] = []
    @Published var containerName: String = CommonsLib.Constants.Container.DefaultName
    @Published var containerMimetype: String = "N/A"
    @Published var containerURL: URL?
    @Published var previewFile: URL?
    @Published var selectedDataFile: URL?
    @Published var isShowingContainerFileSaver = false
    @Published var isShowingFileSaver = false
    @Published var showSignatureRemoveButton = false
    @Published var isTimestampedContainer = false
    @Published var isCadesContainer = false
    @Published var isXadesContainer = false
    @Published var isLastDataFileRemoved = false
    @Published private(set) var containerNotifications: [ContainerNotificationType] = []
    @Published private(set) var errorMessage: (String, [String])?

    private let sharedContainerViewModel: SharedContainerViewModelProtocol
    private let fileOpeningService: FileOpeningServiceProtocol
    private let mimeTypeCache: MimeTypeCacheProtocol
    private let mimeTypeDecoder: MimeTypeDecoderProtocol
    private let fileUtil: FileUtilProtocol
    private let fileManager: FileManagerProtocol
    private let sivaRepository: SivaRepositoryProtocol

    @Published private(set) var signedContainer: SignedContainerProtocol?

    init(
        sharedContainerViewModel: SharedContainerViewModelProtocol,
        fileOpeningService: FileOpeningServiceProtocol,
        mimeTypeCache: MimeTypeCacheProtocol,
        mimeTypeDecoder: MimeTypeDecoderProtocol,
        fileUtil: FileUtilProtocol,
        fileManager: FileManagerProtocol,
        sivaRepository: SivaRepositoryProtocol
    ) {
        self.sharedContainerViewModel = sharedContainerViewModel
        self.fileOpeningService = fileOpeningService
        self.mimeTypeCache = mimeTypeCache
        self.mimeTypeDecoder = mimeTypeDecoder
        self.fileUtil = fileUtil
        self.fileManager = fileManager
        self.sivaRepository = sivaRepository
    }

    func loadContainerData(signedContainer: SignedContainerProtocol?) async {
        SigningViewModel.logger.debug("Loading container data")
        let openedContainer = (signedContainer ?? sharedContainerViewModel.currentContainer()) as? any SignedContainerProtocol
        guard let openedContainer else {
            SigningViewModel.logger.error("Cannot load container data. Signed container is nil.")
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

        SigningViewModel.logger.debug("Container data loaded")
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
            SigningViewModel.logger.error("Unable to get container to create copy for saving")
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

            let tempSavedFileLocation = savedFilesDirectory.appendingPathComponent(filename)

            if fileManager.fileExists(atPath: tempSavedFileLocation.path) {
                do {
                    try fileManager.removeItem(at: tempSavedFileLocation)
                } catch {
                    SigningViewModel.logger.error("Unable to remove existing file: \(error.localizedDescription)")
                    return nil
                }
            }

            do {
                try fileManager.copyItem(at: containerLocation, to: tempSavedFileLocation)
            } catch {
                SigningViewModel.logger.error("Unable to copy file: \(error.localizedDescription)")
                return nil
            }

            return tempSavedFileLocation
        } catch {
            SigningViewModel.logger.error("Unable to get cache directory: \(error.localizedDescription)")
            return nil
        }
    }

    func removeSavedFilesDirectory(savedFilesDirectory: URL? = nil) {
        do {
            let directory = try savedFilesDirectory ?? Directories.getCacheDirectory(
                subfolder: CommonsLib.Constants.Folder.SavedFiles,
                fileManager: fileManager
            )
            try fileManager.removeItem(at: directory)
            SigningViewModel.logger.debug("Saved Files directory removed")
        } catch {
            SigningViewModel.logger.error("Unable to delete saved files directory: \(error.localizedDescription)")
        }
    }

    @discardableResult
    public func renameContainer(to newName: String) async -> URL? {
        do {
            return try await signedContainer?.renameContainer(to: newName)
        } catch {
            SigningViewModel.logger.error("Unable to rename container: \(error)")
            if let digiDocError = error as? DigiDocError {
                switch digiDocError {
                case .containerRenamingFailed(let errorDetail),
                        .containerSavingFailed(let errorDetail):
                    errorMessage = ("Failed to rename file", [errorDetail.userInfo["fileName"] ?? ""])
                default:
                    errorMessage = ("General error", [])
                }
            } else {
                errorMessage = ("General error", [])
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

            if Constants.MimeType.SignatureContainers.contains(mimeType) {
                do {
                    try await openNestedContainer(fileURL: fileURL, isSivaConfirmed: isSivaConfirmed)
                } catch {
                    SigningViewModel.logger.error("Failed to open nested container: \(error)")
                    errorMessage = ("Failed to open container", [dataFile.fileName])
                    if error.localizedDescription.contains("Online validation disabled") {
                        SigningViewModel.logger.error(
                            "Unable to open container '\([dataFile.fileName])'. Sending to SiVa not allowed."
                        )
                        errorMessage = nil
                    } else {
                        SigningViewModel.logger.error("Failed to open nested container: \(error)")
                        errorMessage = ("Failed to open container", [dataFile.fileName])
                    }
                }
            } else {
                previewFile = fileURL
            }
        case .failure:
            errorMessage = ("Failed to open file", [dataFile.fileName])
        }
    }

    func handleSaveFile(dataFile: DataFileWrapper) async {
        let result = await getDataFileURL(dataFile)

        switch result {
        case .success(let fileURL):
            selectedDataFile = fileURL
            isShowingFileSaver = true

        case .failure:
            errorMessage = ("Failed to save file", [dataFile.fileName])
            isShowingFileSaver = false
        }
    }

    func isSivaConfirmationNeeded(dataFile: DataFileWrapper) async -> Bool {
        let result = await getDataFileURL(dataFile)

        switch result {
        case .success(let fileURL):
            return await sivaRepository.isSivaConfirmationNeeded(files: [fileURL])
        case .failure:
            errorMessage = ("Failed to open container", [dataFile.fileName])
            return false
        }
    }

    func isNestedContainer() -> Bool {
        return sharedContainerViewModel.isNestedContainer(
            sharedContainerViewModel.currentContainer()
        )
    }

    func handleBackButton() async -> Bool {
        if sharedContainerViewModel.containers().count > 1 {
            sharedContainerViewModel.removeLastContainer()
            let currentContainer = sharedContainerViewModel.currentContainer() as? any SignedContainerProtocol
            sharedContainerViewModel.setSignedContainer(currentContainer)
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
            SigningViewModel.logger.error(
                "Unable to remove signature from container. SignedContainer or containerURL is nil"
            )
            errorMessage = ("Failed to remove signature from container", [])
            return
        }

        do {
            let container = try await container.removeSignature(index: signature.pos, containerFile: containerFile)
            await loadContainerData(signedContainer: container)
        } catch {
            SigningViewModel.logger.error("Unable to remove signature from container. \(error)")
            errorMessage = ("Failed to remove signature from container", [])
            return
        }
    }

    func removeDataFile(_ dataFile: DataFileWrapper) async {
        guard let container = signedContainer, let containerFile = containerURL else {
            SigningViewModel.logger.error(
                "Unable to remove file from container. SignedContainer or containerURL is nil"
            )
            errorMessage = ("Failed to remove file from container", [dataFile.fileName])
            return
        }

        guard let index = dataFiles.firstIndex(where: { $0.fileId == dataFile.fileId }) else {
            SigningViewModel.logger.error(
                "Unable to remove file from container. File not found in container"
            )
            errorMessage = ("Failed to remove file from container", [dataFile.fileName])
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
            SigningViewModel.logger.error("Unable to remove file from container. \(error)")
            errorMessage = ("Failed to remove file from container", [dataFile.fileName])
            return
        }
    }

    private func openNestedContainer(fileURL: URL, isSivaConfirmed: Bool) async throws {
        let container = try await fileOpeningService
            .openOrCreateContainer(dataFiles: [fileURL], isSivaConfirmed: isSivaConfirmed)
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
}
