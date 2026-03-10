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
import UtilsLib
import CommonsLib

public struct TSLUtil: TSLUtilProtocol {

    private let fileManager: FileManagerProtocol

    public init(
        fileManager: FileManagerProtocol
    ) {
        self.fileManager = fileManager
    }

    public func setupTSLFiles(
        tsls: [String] = [],
        destinationDir: URL,
    ) throws {
        let tslFiles = !tsls.isEmpty ? tsls : Bundle.module.paths(
            forResourcesOfType: "xml",
            inDirectory: CommonsLib.Constants.Configuration.TslFilesFolder
        )

        try createDirectoryIfNotExist(at: destinationDir)

        for filePath in tslFiles {
            let fileName = (filePath as NSString).lastPathComponent

            if isXMLFile(
                fileName
            ), shouldCopyTSL(
                from: filePath,
                to: destinationDir.appending(path: fileName).resolvedPath,
            ) {
                try copyTSL(
                    from: filePath,
                    to: destinationDir.appending(path: fileName).resolvedPath,
                )

                try removeExistingETag(
                    at: destinationDir.appending(path: fileName).resolvedPath,
                )
            }
        }
    }

    public func readSequenceNumber(from inputStreamURL: URL) throws -> Int {
        let parser = XMLParser(contentsOf: inputStreamURL)
        let tslSequenceNumberElement = ["TSLSequenceNumber", "tsl:TSLSequenceNumber"]

        var sequenceNumber: Int?

        let delegate = TSLParserDelegate(sequenceNumberElements: tslSequenceNumberElement)
        parser?.delegate = delegate

        if parser?.parse() == true, let foundSequenceNumber = delegate.foundSequenceNumber {
            sequenceNumber = foundSequenceNumber
        }

        if let sequenceNumber = sequenceNumber {
            return sequenceNumber
        } else {
            throw TSLUtilError.sequenceNumberError(message: "Error reading version from TSL")
        }
    }

    private func isXMLFile(_ filename: String) -> Bool {
        return filename.hasSuffix(".xml")
    }

    private func shouldCopyTSL(
        from sourcePath: String,
        to destinationPath: String,
    ) -> Bool {
        if !fileManager.fileExists(atPath: destinationPath) {
            return true
        } else {
            do {
                let assetURL = URL(fileURLWithPath: sourcePath)
                let cachedURL = URL(fileURLWithPath: destinationPath)

                let assetsTSLVersion = try readSequenceNumber(from: assetURL)
                let cachedTSLVersion = try readSequenceNumber(from: cachedURL)

                return assetsTSLVersion > cachedTSLVersion
            } catch {
                return false
            }
        }
    }

    private func copyTSL(
        from sourcePath: String,
        to destinationPath: String,
    ) throws {
        if fileManager.fileExists(atPath: destinationPath) {
            try fileManager.removeItem(atPath: destinationPath)
        }

        try fileManager.copyItem(atPath: sourcePath, toPath: destinationPath)
    }

    private func removeExistingETag(
        at filePath: String,
    ) throws {
        let eTagURL = URL(fileURLWithPath: filePath).appendingPathExtension("etag")
        if fileManager.fileExists(atPath: eTagURL.resolvedPath) {
            try fileManager.removeItem(atPath: eTagURL.resolvedPath)
        }
    }

    private func createDirectoryIfNotExist(
        at url: URL,
    ) throws {
        if !fileManager.fileExists(atPath: url.resolvedPath) {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
    }
}
