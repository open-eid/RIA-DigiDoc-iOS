import Foundation
import OSLog
import System
import ZIPFoundation

public struct FileUtil: FileUtilProtocol {

    private static let logger = Logger(subsystem: "ee.ria.digidoc.UtilsLib", category: "FileUtil")

    public func getMimeTypeFromZipFile(
        from zipFileURL: URL,
        fileNameToFind: String
    ) async throws -> String? {
        let archive = try Archive(url: zipFileURL, accessMode: .read)

        if let entry = archive.first(where: { $0.path.contains(fileNameToFind) }) {
            let extractedFile = try await Directories.getTempDirectory(subfolder: "tempfiles").validURL()
                .appendingPathComponent(entry.path)
            let fileManager = FileManager.default

            if fileManager.fileExists(atPath: extractedFile.path) {
                try fileManager.removeItem(at: extractedFile)
            }

            _ = try archive.extract(entry, to: extractedFile)
            let mimetypeContent = try String(contentsOf: extractedFile)
            return mimetypeContent.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return nil
    }

    // Check file path so its valid and is not modified by someone else
    public func getValidFileInApp(currentURL: URL) throws -> URL? {
        let directories: [FileManager.SearchPathDirectory] = [
            .applicationDirectory,
            .documentDirectory,
            .downloadsDirectory,
            .userDirectory,
            .libraryDirectory,
            .allLibrariesDirectory
        ]

        for directory in directories {
            guard let directoryURL = FileManager.default.urls(for: directory, in: .userDomainMask).first else {
                continue
            }

            var subdirectoryURLs = [URL]()

            do {
                subdirectoryURLs = try FileManager.default.contentsOfDirectory(
                    at: directoryURL,
                    includingPropertiesForKeys: nil,
                    options: .skipsHiddenFiles
                )
            } catch {
                continue
            }

            let resolvedCurrentUrl = currentURL.resolvingSymlinksInPath()

            for subdirectoryURL in subdirectoryURLs {
                let resolvedSubdirectoryURL = subdirectoryURL.resolvingSymlinksInPath()
                let resolvedSubdirectoryPath = resolvedSubdirectoryURL.path

                if FilePath(stringLiteral: resolvedCurrentUrl.path).lexicallyNormalized().starts(
                    with: FilePath(stringLiteral: resolvedSubdirectoryPath)
                ) ||
                    FilePath(stringLiteral: resolvedCurrentUrl.path).lexicallyNormalized().starts(
                        with: FilePath(
                            stringLiteral: FileManager.default.temporaryDirectory.resolvingSymlinksInPath().path
                        )
                    ) {
                    return resolvedCurrentUrl
                }
            }
        }
        return nil
    }

    // Check if file is opened externally (outside of application)
    public func isFileFromAppGroup(url: URL, appGroupURL: URL? = nil) throws -> Bool {
        let appGroupUrl = try appGroupURL ?? Directories.getSharedFolder()
        let resolvedAppGroupURL = appGroupUrl.deletingLastPathComponent().resolvingSymlinksInPath()

        let normalizedURL = FilePath(stringLiteral: url.resolvingSymlinksInPath().path).lexicallyNormalized()

        let resolvedAppGroupFilePath = FilePath(
            stringLiteral: resolvedAppGroupURL.deletingLastPathComponent().path
        )

        let isFromAppGroup = normalizedURL.starts(with: resolvedAppGroupFilePath)

        if isFromAppGroup {
            return true
        }

        return false
    }

    public func isFileFromiCloud(fileURL: URL) -> Bool {
        do {
            let urlResourceValues = try fileURL.resourceValues(forKeys: [.isUbiquitousItemKey])

            if let isUbiquitousItem = urlResourceValues.isUbiquitousItem, isUbiquitousItem {
                return true
            }
        } catch {
            FileUtil.logger.error(
                "Unable to check iCloud file '\(fileURL.lastPathComponent)' status: \(error.localizedDescription)"
            )
        }

        return false
    }

    public func isFileDownloadedFromiCloud(fileURL: URL) -> Bool {
        do {
            let values = try fileURL.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey])

            if let downloadingStatus = values.ubiquitousItemDownloadingStatus,
               downloadingStatus == .current {
                return true
            }
        } catch {
            let errorMessage = String(format: "Unable to check iCloud file '%@' download status: %@",
                                      fileURL.lastPathComponent,
                                      error.localizedDescription)
            FileUtil.logger.error("\(errorMessage)")
        }

        return false
    }

    public func downloadFileFromiCloud(fileURL: URL, completion: @escaping @Sendable (URL?) -> Void) {
        do {
            try FileManager.default.startDownloadingUbiquitousItem(at: fileURL)
            FileUtil.logger.debug("Downloading file '\(fileURL.lastPathComponent)' from iCloud")

            Task { @Sendable in
                while !isFileDownloadedFromiCloud(fileURL: fileURL) {
                    try await Task.sleep(nanoseconds: 500_000_000)
                }
                FileUtil.logger.debug("iCloud file '\(fileURL.lastPathComponent)' downloaded")
                completion(fileURL)
            }
        } catch {
            FileUtil.logger
                .error(
                    "Unable to start iCloud file '\(fileURL.lastPathComponent)' download: \(error.localizedDescription)"
                )
            completion(nil)
        }
    }

    public func getAllFileURLs(from folderURL: URL) -> [URL] {
        let fileManager = FileManager.default
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
            return fileURLs
        } catch {
            return []
        }
    }

    public func removeSharedFiles(url: URL?) throws {
        let sharedFilesFolder = try url ?? Directories.getSharedFolder()

        let contents = try sharedFilesFolder.folderContents()

        for fileURL in contents {
            try FileManager.default.removeItem(at: fileURL)
        }
    }
}
