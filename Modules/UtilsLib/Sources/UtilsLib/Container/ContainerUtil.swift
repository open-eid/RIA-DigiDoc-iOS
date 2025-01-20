import Foundation

public struct ContainerUtil {
    public static func getSignatureContainerFile(for fileURL: URL, in directory: URL) -> URL {
        let fileManager = FileManager.default
        let fileExtension = fileURL.pathExtension
        let baseName = fileURL.deletingPathExtension().lastPathComponent
        var uniqueFileURL = fileURL
        var fileNameCounter = 1

        while fileManager.fileExists(atPath: uniqueFileURL.path) {
            let newFileName = "\(baseName)-\(fileNameCounter)"
            if !fileExtension.isEmpty {
                uniqueFileURL = directory.appendingPathComponent(newFileName).appendingPathExtension(fileExtension)
            } else {
                uniqueFileURL = directory.appendingPathComponent(newFileName)
            }
            fileNameCounter += 1
        }

        return uniqueFileURL
    }
}
