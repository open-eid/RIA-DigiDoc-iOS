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
class FileOpeningViewModel: FileOpeningViewModelProtocol, Loggable {
    var isFileOpeningLoading: Bool = false
    var isNavigatingToSigningView: Bool = false
    var isNavigatingToEncryptView: Bool = false
    var isSivaConfirmed = false

    var signedContainer: SignedContainerProtocol = SignedContainer(
        fileManager: Container.shared.fileManager(),
        containerUtil: Container.shared.containerUtil()
    )

    var errorMessage: ToastMessage?

    private let fileOpeningRepository: FileOpeningRepositoryProtocol
    private let sivaRepository: SivaRepositoryProtocol
    private let sharedContainerViewModel: SharedContainerViewModelProtocol
    private let fileUtil: FileUtilProtocol
    private let fileManager: FileManagerProtocol

    init(
        fileOpeningRepository: FileOpeningRepositoryProtocol,
        sivaRepository: SivaRepositoryProtocol,
        sharedContainerViewModel: SharedContainerViewModelProtocol,
        fileUtil: FileUtilProtocol,
        fileManager: FileManagerProtocol
    ) {
        self.fileOpeningRepository = fileOpeningRepository
        self.sivaRepository = sivaRepository
        self.sharedContainerViewModel = sharedContainerViewModel
        self.fileUtil = fileUtil
        self.fileManager = fileManager
    }

    private var files: [URL] = []

    func handleFiles() async {
        do {
            FileOpeningViewModel.logger().info("Handling chosen files from file system or from external sources")
            let validFiles = try await fileOpeningRepository.getValidFiles(
                sharedContainerViewModel.getFileOpeningResult() ?? .failure(FileOpeningError.noDataFiles)
            )

            try fileUtil.removeSharedFiles(url: Directories.getSharedFolder(fileManager: fileManager))

            FileOpeningViewModel.logger().info("Found \(validFiles.count, privacy: .public) valid file(s)")

            if validFiles.isEmpty {
                FileOpeningViewModel.logger().info("No valid files found")
                throw FileOpeningError.noDataFiles
            }

            files = validFiles
        } catch {
            FileOpeningViewModel.logger().error(
                "Unable to handle files. \(String(reflecting: error), privacy: .public)"
            )
            handleError(error)
        }
    }

    func handleSivaConfirmation() async {
        sharedContainerViewModel.setAddedFilesCount(addedFiles: files.count)

        do {
            guard let firstFile = files.first else {
                throw FileOpeningError.noDataFiles
            }

            var firstFileUrl = firstFile

            let isDdoc = await firstFile.isDdoc()
            let isCdoc = await firstFile.isCdoc()

            if isDdoc || isCdoc {
                firstFileUrl = await handleExternalDdocAndCdoc(firstFile)
            }

            let uniqueContainerUrl = try getUniqueContainerUrl(file: firstFileUrl)

            files[0] = uniqueContainerUrl

            let container = try await openOrCreateContainer(withUrls: files)
            if let signedContainer = container as? SignedContainerProtocol {
                if await signedContainer.getContainerMimetype() == Constants.MimeType.Asics {
                    try await handleAsicsSivaConfirmation(parentContainer: signedContainer)
                } else {
                    sharedContainerViewModel.setSignedContainer(signedContainer)
                }

                try await signedContainer.getRawContainerFile()?.markAsOpened()
            } else if let cryptoContainer = container as? CryptoContainerProtocol {
                sharedContainerViewModel.setCryptoContainer(cryptoContainer)
                try await cryptoContainer.getRawContainerFile()?.markAsOpened()
            }

            handleLoadingSuccess(isSivaConfirmed: true)
        } catch {
            FileOpeningViewModel.logger().error(
                "Unable to handle container confirmation. \(String(reflecting: error), privacy: .public)"
            )
            handleError(error)
        }
    }

    private func handleExternalDdocAndCdoc(_ file: URL) async -> URL {
        let currentExtension = file.pathExtension.lowercased()

        let isDdoc = await file.isDdoc()
        let isCdoc = await file.isCdoc()

        let renamedExtension: String?

        if isDdoc && currentExtension != Constants.Extension.Ddoc {
            renamedExtension = Constants.Extension.Ddoc
        } else if isCdoc && currentExtension != Constants.Extension.Cdoc {
            renamedExtension = Constants.Extension.Cdoc
        } else {
            renamedExtension = nil
        }

        guard let renamedExtension else { return file }

        let renamedURL = file
            .deletingPathExtension()
            .appendingPathExtension(renamedExtension)

        do {
            if fileManager.fileExists(atPath: renamedURL.path) {
                try fileManager.removeItem(at: renamedURL)
            }

            try fileManager.moveItem(at: file, to: renamedURL)
            return renamedURL
        } catch {
            FileOpeningViewModel.logger().error(
                "Unable to rename container. \(String(reflecting: error), privacy: .public)"
            )
        }

        return file
    }

    func handleSivaCancellation() async {
        sharedContainerViewModel.setAddedFilesCount(addedFiles: files.count)

        let fileMimetype = await files.first?.mimeType()

        guard let mimetype = fileMimetype else {
            handleError()
            return
        }

        if mimetype == Constants.MimeType.Ddoc {
            handleError()
        } else if mimetype == Constants.MimeType.Asics {
            do {
                let container = try await fileOpeningRepository
                    .openOrCreateContainer(urls: files, isSivaConfirmed: false)
                sharedContainerViewModel.setSignedContainer(container)
                FileOpeningViewModel.logger().info("Asics signed container set successfully")
                handleLoadingSuccess(isSivaConfirmed: false)
            } catch {
                FileOpeningViewModel.logger().error(
                    "Unable to handle SiVa container. \(String(reflecting: error), privacy: .public)"
                )
                handleError(error)
            }
        }
    }

    func showFileAddedMessage() async -> Bool {
        let container = sharedContainerViewModel.currentContainer() as? any SignedContainerProtocol

        return await !(container?.isExistingContainer() ?? true)
    }

    func addedFilesCount() -> Int {
        return sharedContainerViewModel.getAddedFilesCount()
    }

    func handleError() {
        errorMessage = nil
        isFileOpeningLoading = false
        isNavigatingToSigningView = false
        isNavigatingToEncryptView = false
    }

    func isSivaConfirmationNeeded() async -> Bool {
        return await fileOpeningRepository.isSivaConfirmationNeeded(files: files)
    }

    private func getUniqueContainerUrl(file: URL) throws -> URL {
        let signedContainersDirectory = try Directories.getCacheDirectory(
            subfolders: [Constants.Folder.ContainerFolder],
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

        return renamedContainerFile
    }

    private func handleAsicsSivaConfirmation(parentContainer: SignedContainerProtocol) async throws {
        let isTimestampedContainer = await sivaRepository.isTimestampedContainer(signedContainer: parentContainer)
        let isCades = await parentContainer.isCades()
        let isXades = await parentContainer.isXades()
        if isTimestampedContainer && !isCades && !isXades {
            let nestedTimestampedContainer = try await sivaRepository
                .getTimestampedContainer(parentContainer: parentContainer)
            sharedContainerViewModel.setSignedContainer(nestedTimestampedContainer)
        } else {
            sharedContainerViewModel.setSignedContainer(parentContainer)
        }
    }

    private func handleLoadingSuccess(isSivaConfirmed: Bool) {
        let currentContainer = sharedContainerViewModel.currentContainer()
        let isSignedContainer = (currentContainer as? SignedContainerProtocol) != nil
        let isCryptoContainer = (currentContainer as? CryptoContainerProtocol) != nil
        self.isSivaConfirmed = isSivaConfirmed
        isFileOpeningLoading = false
        isNavigatingToSigningView = isSignedContainer
        isNavigatingToEncryptView = isCryptoContainer
    }

    private func handleError(_ error: Error) {
        if let dde = error as? DigiDocError {
            FileOpeningViewModel.logger().error("\(String(reflecting: dde), privacy: .public)")
            errorMessage = createToastMessage(for: dde)
            let fileName = dde.errorDetail.userInfo["fileName"] as? String
            guard let file = fileName else { return }
            removeUnsuccessfulContainer(fileName: file)
        } else if let foe = error as? FileOpeningError {
            FileOpeningViewModel.logger().error(
                "\(String(reflecting: foe), privacy: .public)"
            )
            errorMessage = createToastMessage(for: foe)
        } else {
            FileOpeningViewModel.logger().error(
                "\(String(reflecting: error.localizedDescription), privacy: .public)"
            )
            errorMessage = ToastMessage(key: "General error")
        }
    }

    private func removeUnsuccessfulContainer(fileName: String) {
        do {
            let containerUrl = try Directories.getCacheDirectory(
                subfolders: [Constants.Folder.ContainerFolder],
                fileManager: fileManager
            )
                .appending(path: fileName, directoryHint: .notDirectory)

            try fileManager.removeItem(at: containerUrl)
        } catch {
            FileOpeningViewModel.logger().error(
                "Unable to remove unsuccessful container: \(String(reflecting: error))"
            )
        }
    }

    private func openOrCreateContainer(withUrls urls: [URL]) async throws -> GeneralContainer {
        let fileOpeningMethod = sharedContainerViewModel.getFileOpeningMethod()
        switch fileOpeningMethod {
        case .all:
            guard let firstFile = urls.first else { throw FileOpeningError.noDataFiles }
            let isCryptoContainer = await firstFile.isCryptoContainer()
            if isCryptoContainer {
                return try await fileOpeningRepository.openOrCreateCryptoContainer(urls: urls)
            }
            return try await fileOpeningRepository.openOrCreateContainer(urls: files, isSivaConfirmed: true)
        case .signing:
            return try await fileOpeningRepository.openOrCreateContainer(urls: files, isSivaConfirmed: true)
        case .crypto:
            return try await fileOpeningRepository.openOrCreateCryptoContainer(urls: urls)
        }
    }

    private func createToastMessage(for error: DigiDocError) -> ToastMessage {
        switch error {
        case .containerCreationFailed(let errorDetail),
                .containerOpeningFailed(let errorDetail),
                .containerSavingFailed(let errorDetail):
            return ToastMessage(
                key: "Failed to open container",
                args: [errorDetail.userInfo["fileName"] as? String ?? ""]
            )
        case .addingFilesToContainerFailed(let errorDetail):
            return ToastMessage(
                key: "Failed to open file",
                args: [errorDetail.userInfo["fileName"] as? String ?? ""]
            )
        case .containerDataFileSavingFailed(let errorDetail):
            return ToastMessage(
                key: "Failed to save file",
                args: [errorDetail.userInfo["fileName"] as? String ?? ""]
            )
        case .alreadyInitialized:
            return ToastMessage(key: "Libdigidocpp is already initialized")
        default:
            return ToastMessage(key: "General error")
        }
    }

    private func createToastMessage(for error: FileOpeningError) -> ToastMessage {
        switch error {
        case .unableToRetrieveFileSize, .invalidFileSize:
            return ToastMessage(key: "Invalid file size")
        case .emptyFile, .noDataFiles:
            return ToastMessage(key: "Could not load selected files")
        }
    }
}
