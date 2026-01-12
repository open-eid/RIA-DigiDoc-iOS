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
import CommonsLib

public struct ContainerUtil: ContainerUtilProtocol, Loggable {

    private let dataFileDirectory = "%@-data-files"

    let fileManager: FileManagerProtocol

    init(fileManager: FileManagerProtocol = Container.shared.fileManager()) {
        self.fileManager = fileManager
    }

    public func getContainerFile(
        for fileURL: URL,
        in directory: URL
    ) -> URL {
        let fileExtension = fileURL.pathExtension
        let baseName = fileURL.deletingPathExtension().lastPathComponent
        var uniqueFileURL = directory.appending(path: fileURL.lastPathComponent)
        var fileNameCounter = 1

        while fileManager.fileExists(atPath: uniqueFileURL.path) {
            let newFileName = "\(baseName) (\(fileNameCounter))"
            if !fileExtension.isEmpty {
                uniqueFileURL = directory.appending(path: "\(newFileName).\(fileExtension)")
            } else {
                uniqueFileURL = directory.appending(path: newFileName)
            }
            fileNameCounter += 1
        }

        return uniqueFileURL
    }

    public func getSignatureContainersDir() throws -> URL {
        let signedContainersDirectory = try Directories.getCacheDirectory(
            subfolders: [Constants.Folder.SignedContainerFolder],
            fileManager: fileManager
        )

        do {
            try fileManager
                .createDirectory(at: signedContainersDirectory, withIntermediateDirectories: true, attributes: [:])
            ContainerUtil.logger().info(
                "Directories created or already exist for \(signedContainersDirectory.resolvedPath)"
            )
        } catch {
            ContainerUtil.logger().error("Unable to create signature containers dir: \(error.localizedDescription)")
            throw error
        }

        return signedContainersDirectory
    }

    public func getContainerDataFilesDir(
        containerFile: URL?
    ) throws -> URL {
        let signatureDir = try getSignatureContainersDir()
        let cacheDir = try Directories.getCacheDirectory(fileManager: fileManager)

        if containerFile?.deletingLastPathComponent() == signatureDir {
            return createDataFileDirectory(
                directory: cacheDir,
                container: containerFile
            )
        } else {
            return createDataFileDirectory(
                directory: containerFile?.deletingLastPathComponent(),
                container: containerFile
            )
        }
    }

    private func createDataFileDirectory(
        directory: URL?,
        container: URL?
    ) -> URL {
        var index = 0
        let baseDirectory = directory ?? URL(fileURLWithPath: "")

        while true {
            var dirName = String(format: dataFileDirectory, container?.lastPathComponent ?? "")
            if index > 0 {
                dirName.append("\(index)")
            }

            let targetDirectory = baseDirectory.appending(path: dirName, directoryHint: .isDirectory)

            var isDirectory: ObjCBool = false
            let exists = fileManager.fileExists(atPath: targetDirectory.resolvedPath, isDirectory: &isDirectory)

            if !exists || isDirectory.boolValue {
                do {
                    try fileManager.createDirectory(
                        at: targetDirectory,
                        withIntermediateDirectories: true,
                        attributes: [:]
                    )
                    if let base = directory {
                        ContainerUtil.logger().info("Directories created or already exist for \(base.resolvedPath)")
                    }
                } catch {
                    ContainerUtil.logger().error("Failed to create directory: \(error.localizedDescription)")
                }

                return targetDirectory
            }

            index += 1
        }
    }
}
