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
import CryptoSwift
import CommonsLib
import UtilsLib

@Observable
@MainActor
class CryptoFileOpeningViewModel: CryptoFileOpeningViewModelProtocol, Loggable {
    var isFileOpeningLoading: Bool = false
    var isNavigatingToNextView: Bool = false

    var cryptoContainer: CryptoContainerProtocol =  CryptoContainer(
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
            CryptoFileOpeningViewModel.logger().info("Handling chosen files from file system or from external sources")
            let validFiles = try await fileOpeningRepository.getValidFiles(
                sharedContainerViewModel.getFileOpeningResult() ?? .failure(FileOpeningError.noDataFiles)
            )

            try fileUtil.removeSharedFiles(url: Directories.getSharedFolder(fileManager: fileManager))

            CryptoFileOpeningViewModel.logger().info("Found \(validFiles.count) valid file(s)")

            if validFiles.isEmpty {
                CryptoFileOpeningViewModel.logger().info("No valid files found")
                throw FileOpeningError.noDataFiles
            }

            files = validFiles
        } catch {
            CryptoFileOpeningViewModel.logger().error("Unable to handle files. \(error)")
            handleError(error)
        }
    }

    func handleConfirmation() async {
        sharedContainerViewModel.setAddedFilesCount(addedFiles: files.count)

        do {
            guard let firstFile = files.first else {
                throw FileOpeningError.noDataFiles
            }

            files[0] = firstFile

            let container = try await fileOpeningRepository.openOrCreateCryptoContainer(urls: files)
            sharedContainerViewModel.setCryptoContainer(container)

            handleLoadingSuccess()
        } catch {
            CryptoFileOpeningViewModel.logger().error("Unable to handle Crypto container. \(error)")
            handleError(error)
        }
    }

    func showFileAddedMessage() async -> Bool {
        let container = sharedContainerViewModel.currentContainer() as? any CryptoContainerProtocol

        return await container?.getRecipients().isEmpty ?? false
    }

    func addedFilesCount() -> Int {
        return sharedContainerViewModel.getAddedFilesCount()
    }

    func handleError() {
        errorMessage = nil
        isFileOpeningLoading = false
        isNavigatingToNextView = false
    }

    private func getFirstFileLocation(file: URL) async throws -> URL {
        let cryptoContainersDirectory = try Directories.getCacheDirectory(
            subfolders: [Constants.Folder.ContainerFolder],
            fileManager: fileManager
        )

        let movedFileLocation = cryptoContainersDirectory.appending(path: file.lastPathComponent)

        if await file.isContainer() &&
            fileManager.fileExists(atPath: movedFileLocation.path(percentEncoded: false)) {
            try fileManager.removeItem(at: file)
        }

        try fileManager.moveItem(at: file, to: movedFileLocation)

        return movedFileLocation
    }

    private func handleLoadingSuccess() {
        isFileOpeningLoading = false
        isNavigatingToNextView = true
    }

    private func handleError(_ error: Error) {
        let ddeMessage = (error as? CryptoError)?.description ?? error.localizedDescription
        CryptoFileOpeningViewModel.logger().error("\(ddeMessage)")

        if let dde = error as? CryptoError {
            CryptoFileOpeningViewModel.logger().error("\(dde)")
            errorMessage = createToastMessage(for: dde)
        } else {
            errorMessage = ToastMessage(key: error.localizedDescription)
        }
    }

    private func createToastMessage(for error: CryptoError) -> ToastMessage {
        switch error {
        case .containerCreationFailed(let errorDetail),
                .containerOpeningFailed(let errorDetail),
                .containerSavingFailed(let errorDetail):
            return ToastMessage(key: "Failed to open container", args: [errorDetail.userInfo["fileName"] ?? ""])
        case .addingFilesToContainerFailed(let errorDetail):
            return ToastMessage(key: "Failed to open file", args: [errorDetail.userInfo["fileName"] ?? ""])
        case .containerDataFileSavingFailed(let errorDetail):
            return ToastMessage(key: "Failed to save file", args: [errorDetail.userInfo["fileName"] ?? ""])
        default:
            return ToastMessage(key: "General error")
        }
    }
}
