import Foundation
import LibdigidocLibSwift
import CommonsLib

actor FileOpeningService: FileOpeningServiceProtocol {
    func isFileSizeValid(url: URL) async throws -> Bool {
        let resources = try url.resourceValues(forKeys: [.fileSizeKey])

        guard let fileSize = resources.fileSize, fileSize > 0 else {
            throw FileOpeningError.invalidFileSize
        }

        return true
    }

    func getValidFiles(_ result: Result<[URL], Error>) async throws -> [URL] {
        switch result {
        case .success(let urls):
            var validFiles: [URL] = []

            for url in urls where url.startAccessingSecurityScopedResource() {
                defer { url.stopAccessingSecurityScopedResource() }
                if try await isFileSizeValid(url: url) {
                    validFiles.append(try cacheFile(from: url))
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
