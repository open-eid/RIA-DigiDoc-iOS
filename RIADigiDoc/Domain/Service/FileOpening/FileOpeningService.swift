// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import FactoryKit
import LibdigidocLibSwift
import CommonsLib
import UtilsLib
import CryptoSwift

actor FileOpeningService: FileOpeningServiceProtocol {

    private let fileUtil: FileUtilProtocol
    private let fileInspector: FileInspectorProtocol
    private let fileManager: FileManagerProtocol

    init(
        fileUtil: FileUtilProtocol,
        fileInspector: FileInspectorProtocol,
        fileManager: FileManagerProtocol
    ) {
        self.fileUtil = fileUtil
        self.fileInspector = fileInspector
        self.fileManager = fileManager
    }

    func isFileSizeValid(url: URL) async throws -> Bool {
        return try await fileInspector.fileSize(for: url) > 0
    }

    func getValidFiles(
        _ result: Result<[URL], Error>
    ) async throws -> [URL] {
        switch result {
        case .success(let urls):
            var validFiles: [URL] = []

            for url in urls {
                _ = url.startAccessingSecurityScopedResource()

                let validUrl = try await url.validURL(fileUtil: fileUtil)

                defer {
                    url.stopAccessingSecurityScopedResource()
                }

                if try await isFileSizeValid(url: validUrl) {
                    await validFiles.append(try cacheFile(from: validUrl))
                }
            }

            return validFiles
        case .failure(let error):
            throw error
        }
    }

    func openOrCreateContainer(dataFiles: [URL], isSivaConfirmed: Bool) async throws -> SignedContainerProtocol {
        return try await SignedContainer.openOrCreate(dataFiles: dataFiles, isSivaConfirmed: isSivaConfirmed)
    }

    func openOrCreateCryptoContainer(dataFiles: [URL]) async throws -> CryptoContainerProtocol {
        return try await CryptoContainer.openOrCreate(dataFiles: dataFiles)
    }

    private func cacheFile(
        from sourceURL: URL,
    ) async throws -> URL {
        let signedContainersDirectory = try Directories.getCacheDirectory(
            subfolders: [Constants.Folder.ContainerFolder],
            fileManager: fileManager
        )

        // Check if file is already in signed containers directory (like Recent documents)
        if sourceURL.absoluteString.hasPrefix(signedContainersDirectory.absoluteString) {
            return sourceURL
        }

        let signedContainersDataFilesDirectory = signedContainersDirectory
            .appending(path: Constants.Folder.Temp, directoryHint: .isDirectory)

        if !fileManager.fileExists(atPath: signedContainersDirectory.resolvedPath) ||
            !fileManager.fileExists(atPath: signedContainersDataFilesDirectory.resolvedPath) {
            try fileManager.createDirectory(
                at: signedContainersDataFilesDirectory,
                withIntermediateDirectories: true,
                attributes: nil)
        }

        let destinationURL = signedContainersDataFilesDirectory.appending(path: sourceURL.lastPathComponent)

        if fileManager.fileExists(atPath: destinationURL.resolvedPath) {
            try fileManager.removeItem(at: destinationURL)
        }

        try fileManager.copyItem(at: sourceURL, to: destinationURL)

        return destinationURL
    }
}
