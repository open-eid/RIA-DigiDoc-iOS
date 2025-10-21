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

    private static let logger = Logger(
        subsystem: "ee.ria.digidoc.CommonsLib.CommonsTestShared",
        category: "TestFileUtil"
    )

    private static let bundleIdentifier =  Bundle.main.bundleIdentifier ?? "ee.ria.digidoc"

    public init() {}

    public static func getTemporaryDirectory(
        subfolder: String,
        fileManager: FileManagerProtocol = Container.shared.fileManager()
    ) -> URL {
        var tempDirectory: URL
        if #available(iOS 16.0, *) {
            tempDirectory = fileManager.temporaryDirectory
                .appending(path: bundleIdentifier, directoryHint: .isDirectory)
                .appending(path: subfolder, directoryHint: .isDirectory)
        } else {
            tempDirectory = fileManager.temporaryDirectory
                .appendingPathComponent(bundleIdentifier, isDirectory: true)
                .appendingPathComponent(subfolder, isDirectory: true)
        }

        do {
            if !fileManager.fileExists(atPath: tempDirectory.path) {
                try fileManager.createDirectory(
                    at: tempDirectory,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            }
        } catch {
            logger.error(
                "Unable to create temporary file directory or remove existing file: \(error.localizedDescription)"
            )
        }

        return tempDirectory
    }

    public static func createSampleFile(
        name: String = "TestFile-\(UUID())",
        withExtension ext: String = "txt",
        contents: String? = "Test content",
        subfolder: String = "TestFileUtil",
        fileManager: FileManagerProtocol = Container.shared.fileManager()
    ) -> URL {
        var tempFileDirectory = getTemporaryDirectory(subfolder: subfolder)

        if #available(iOS 16.0, *) {
            tempFileDirectory = tempFileDirectory
                .appending(component: name, directoryHint: .notDirectory)
                .appendingPathExtension(ext)
        } else {
            tempFileDirectory = tempFileDirectory
                .appendingPathComponent(name, isDirectory: false)
                .appendingPathExtension(ext)
        }

        let isCreated = fileManager
            .createFile(
                atPath: tempFileDirectory.path,
                contents: contents?.data(
                    using: .utf8
                ), attributes: nil
            )

        if !isCreated {
            logger.error("Unable to create file at path: \(tempFileDirectory.path)")
        }

        return tempFileDirectory
    }

    public static func pathForResourceFile(fileName: String, ext: String) -> URL? {
        return Bundle.module.url(forResource: fileName, withExtension: ext)
    }
}
