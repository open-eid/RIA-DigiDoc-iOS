import Foundation
import LibdigidocLibSwift
import CommonsLib
import UtilsLib

actor FileOpeningService: FileOpeningServiceProtocol {

    private let fileUtil: FileUtilProtocol

    @MainActor
    init(
        fileUtil: FileUtilProtocol? = nil
    ) {
        self.fileUtil = fileUtil ?? UtilsLibAssembler.shared.resolve(FileUtilProtocol.self)
    }

    func isFileSizeValid(url: URL) async throws -> Bool {
        let resources = try url.resourceValues(forKeys: [.fileSizeKey])

        guard let fileSize = resources.fileSize, fileSize > 0 else {
            throw FileOpeningError.invalidFileSize
        }

        return true
    }

    @MainActor
    func getValidFiles(
        _ result: Result<[URL], Error>
    ) async throws -> [URL] {
        switch result {
        case .success(let urls):
            var validFiles: [URL] = []

            for url in urls {
                let validUrl = try url.validURL()
                let validFileUrl = try fileUtil.getValidFileInApp(currentURL: validUrl)
                let requiresScopedAccess = try validFileUrl == nil && !fileUtil.isFileFromAppGroup(
                    url: validUrl,
                    appGroupURL: nil
                )

                if requiresScopedAccess {
                    guard validUrl.startAccessingSecurityScopedResource() else {
                        continue
                    }
                }

                defer {
                    if requiresScopedAccess {
                        validUrl.stopAccessingSecurityScopedResource()
                    }
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

    func openOrCreateContainer(dataFiles: [URL]) async throws -> SignedContainer {
        return try await SignedContainer.openOrCreate(dataFiles: dataFiles)
    }

    private func cacheFile(from sourceURL: URL) throws -> URL {
        let fileManager = FileManager.default
        let cachesDirectory = try fileManager.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false)
        let signedContainersDirectory = cachesDirectory.appendingPathComponent(
            Constants.Container.SignedContainerFolder,
            isDirectory: true
        )

        // Check if file is already in signed containers directory (like Recent documents)
        if sourceURL.absoluteString.hasPrefix(signedContainersDirectory.absoluteString) {
            return sourceURL
        }

        if !fileManager.fileExists(atPath: signedContainersDirectory.path) {
            try fileManager.createDirectory(
                at: signedContainersDirectory,
                withIntermediateDirectories: true,
                attributes: nil)
        }

        let destinationURL = signedContainersDirectory.appendingPathComponent(sourceURL.lastPathComponent)

        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }

        try fileManager.copyItem(at: sourceURL, to: destinationURL)

        return destinationURL
    }
}
