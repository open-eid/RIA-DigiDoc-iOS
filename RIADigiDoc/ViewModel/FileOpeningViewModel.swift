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
import LibdigidocLibSwift
import CommonsLib
import UtilsLib

@Observable
@MainActor
class FileOpeningViewModel: FileOpeningViewModelProtocol, Loggable {
    var isFileOpeningLoading: Bool = false
    var isNavigatingToNextView: Bool = false
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
            FileOpeningViewModel.logger().debug("Handling chosen files from file system or from external sources")
            let validFiles = try await fileOpeningRepository.getValidFiles(
                sharedContainerViewModel.getFileOpeningResult() ?? .failure(FileOpeningError.noDataFiles)
            )

            try fileUtil.removeSharedFiles(url: Directories.getSharedFolder(fileManager: fileManager))

            FileOpeningViewModel.logger().debug("Found \(validFiles.count) valid file(s)")

            if validFiles.isEmpty {
                FileOpeningViewModel.logger().debug("No valid files found")
                throw FileOpeningError.noDataFiles
            }

            files = validFiles
        } catch {
            FileOpeningViewModel.logger().error("Unable to handle files. \(error)")
            handleError(error)
        }
    }

    func handleSivaConfirmation() async {
        sharedContainerViewModel.setAddedFilesCount(addedFiles: files.count)

        do {
            let container = try await fileOpeningRepository.openOrCreateContainer(urls: files, isSivaConfirmed: true)
            if await container.getContainerMimetype() == Constants.MimeType.Asics {
                try await handleAsicsSivaConfirmation(parentContainer: container)
            } else {
                sharedContainerViewModel.setSignedContainer(container)
            }

            try await container.getRawContainerFile()?.markAsOpened()
            handleLoadingSuccess(isSivaConfirmed: true)
        } catch {
            FileOpeningViewModel.logger().error("Unable to handle SiVa container. \(error)")
            handleError(error)
        }
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
                FileOpeningViewModel.logger().debug("Asics signed container set successfully")
                handleLoadingSuccess(isSivaConfirmed: false)
            } catch {
                FileOpeningViewModel.logger().error("Unable to handle SiVa container. \(error)")
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
        isNavigatingToNextView = false
    }

    func isSivaConfirmationNeeded() async -> Bool {
        return await fileOpeningRepository.isSivaConfirmationNeeded(files: files)
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
        self.isSivaConfirmed = isSivaConfirmed
        isFileOpeningLoading = false
        isNavigatingToNextView = true
    }

    private func handleError(_ error: Error) {
        let ddeMessage = (error as? DigiDocError)?.description ?? error.localizedDescription
        FileOpeningViewModel.logger().error("\(ddeMessage)")

        if let dde = error as? DigiDocError {
            FileOpeningViewModel.logger().error("\(dde)")
            errorMessage = createToastMessage(for: dde)
        } else {
            errorMessage = ToastMessage(key: error.localizedDescription)
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
}
