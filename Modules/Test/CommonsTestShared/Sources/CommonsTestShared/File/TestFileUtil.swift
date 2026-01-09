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
import OSLog
import FactoryKit
import CommonsLib

public struct TestFileUtil {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.CommonsTestShared", category: "TestFileUtil")

    private static let bundleIdentifier = Bundle.main.bundleIdentifier ?? "ee.ria.digidoc"

    public init() {}

    public static func getURL(string: String) throws -> URL {
        guard let url = URL(string: string) else {
            TestFileUtil.logger.error("'\(string)' is not a valid URL")
            throw URLError(.badURL)
        }
        return url
    }

    public static func getTemporaryDirectory(
        subfolder: String,
        fileManager: FileManagerProtocol = Container.shared.fileManager()
    ) throws -> URL {
        let tempDirectory = fileManager.temporaryDirectory
            .appending(path: bundleIdentifier, directoryHint: .isDirectory)
            .appending(path: subfolder, directoryHint: .isDirectory)

        do {
            if !fileManager.fileExists(atPath: tempDirectory.standardizedFileURL.path(percentEncoded: false)) {
                try fileManager.createDirectory(
                    at: tempDirectory,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            }
        } catch {
            TestFileUtil.logger.error(
                "Unable to create temporary file directory or remove existing file: \(error.localizedDescription)"
            )

            throw URLError(.fileDoesNotExist)
        }

        return tempDirectory
    }

    public static func createSampleFile(
        name: String = "TestFile-\(UUID())",
        withExtension ext: String = "txt",
        contents: String? = "Test content",
        subfolder: String = "TestFileUtil",
        fileManager: FileManagerProtocol = Container.shared.fileManager()
    ) throws -> URL {
        let tempFileDirectory = try getTemporaryDirectory(subfolder: subfolder)
            .appending(path: "\(name).\(ext)", directoryHint: .notDirectory)

        let isCreated = fileManager
            .createFile(
                atPath: tempFileDirectory.standardizedFileURL.path(percentEncoded: false),
                contents: contents?.data(
                    using: .utf8
                ), attributes: nil
            )

        if !isCreated {
            TestFileUtil.logger.error(
                "Unable to create file at path: \(tempFileDirectory.standardizedFileURL.path(percentEncoded: false))"
            )

            throw URLError(.fileDoesNotExist)
        }

        return tempFileDirectory
    }

    public static func pathForResourceFile(fileName: String, ext: String) -> URL? {
        return Bundle.module.url(forResource: fileName, withExtension: ext)
    }
}
