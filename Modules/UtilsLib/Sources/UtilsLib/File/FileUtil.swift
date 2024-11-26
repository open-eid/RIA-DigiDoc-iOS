import Foundation
import ZIPFoundation

struct FileUtil: FileUtilProtocol {

    func getMimeTypeFromZipFile(
        from zipFileURL: URL,
        fileNameToFind: String
    ) throws -> String? {
        let archive = try Archive(url: zipFileURL, accessMode: .read)

        if let entry = archive.first(where: { $0.path.contains(fileNameToFind) }) {
            let extractedFile = try Directories.getTempDirectoryURL(subfolder: "tempfiles")
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
}
