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

actor FileOpeningService: FileOpeningServiceProtocol, Loggable {

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
            var firstError: Error?

            for (index, url) in urls.enumerated() {
                _ = url.startAccessingSecurityScopedResource()

                do {
                    let validUrl = try await url.validURL(fileUtil: fileUtil)

                    defer {
                        url.stopAccessingSecurityScopedResource()
                    }

                    let sizeOk = try await isFileSizeValid(url: validUrl)
                    FileOpeningService.logger().info(
                        """
                        phase=app.validate idx=\(index, privacy: .public) \
                        of=\(urls.count, privacy: .public) \
                        ext=\(validUrl.pathExtension.lowercased(), privacy: .public) \
                        dotLead=\(validUrl.lastPathComponent.hasPrefix("."), privacy: .public) \
                        sizeOk=\(sizeOk, privacy: .public)
                        """
                    )

                    if sizeOk {
                        await validFiles.append(try cacheFile(from: validUrl))
                    }
                } catch {
                    let nsError = error as NSError
                    FileOpeningService.logger().error(
                        """
                        phase=app.validateFailed idx=\(index, privacy: .public) \
                        of=\(urls.count, privacy: .public) \
                        errDomain=\(nsError.domain, privacy: .public) \
                        errCode=\(nsError.code, privacy: .public) \
                        userInfoKeys=\(nsError.userInfo.keys.sorted().joined(separator: ","), privacy: .public)
                        """
                    )
                    if firstError == nil {
                        firstError = error
                    }
                }
            }

            if validFiles.isEmpty, let firstError {
                throw firstError
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
