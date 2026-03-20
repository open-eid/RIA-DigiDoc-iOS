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
import CommonsLib
import UtilsLib

struct DocumentsMigrator: DocumentsMigratorProtocol, Loggable {

    private let containerUtil: ContainerUtilProtocol
    private let fileManager: FileManagerProtocol

    init(
        containerUtil: ContainerUtilProtocol,
        fileManager: FileManagerProtocol
    ) {
        self.containerUtil = containerUtil
        self.fileManager = fileManager
    }

    func migrateRecentDocuments() async {
        DocumentsMigrator.logger().info("Migrating recent documents...")

        do {
            let oldAppRecentDocumentsLocation = try fileManager.url(
                for: .cachesDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false)

            let recentDocumentsUrl = try containerUtil.getSignatureContainersDir()

            let oldAppFileURLs = try fileManager.contentsOfDirectory(
                at: oldAppRecentDocumentsLocation,
                includingPropertiesForKeys: nil,
                options: []
            )

            for file in oldAppFileURLs {
                let shouldMigrate = await shouldMigrate(file)
                guard shouldMigrate else { continue }

                do {
                    let destinationFileURL = recentDocumentsUrl.appendingPathComponent(file.lastPathComponent)
                    if fileManager.fileExists(atPath: destinationFileURL.path(percentEncoded: false)) {
                        try fileManager.removeItem(at: destinationFileURL)
                    }

                    try fileManager.moveItem(at: file, to: destinationFileURL)
                } catch {
                    DocumentsMigrator.logger().error(
                        "Unable to migrate file \(file.lastPathComponent): \(String(reflecting: error))"
                    )
                }
            }

            DocumentsMigrator.logger().info("Recent documents migrated successfully")
        } catch {
            DocumentsMigrator.logger().error("Unable to migrate recent documents: \(String(reflecting: error))")
        }
    }

    private func shouldMigrate(_ file: URL) async -> Bool {
        let isContainer = await file.isContainer()
        let isCryptoContainer = await file.isCryptoContainer()
        return isContainer || isCryptoContainer
    }
}
