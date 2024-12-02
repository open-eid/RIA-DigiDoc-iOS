import Foundation
import ZIPFoundation

public class TestContainerUtil {

    public init() {}

    public static func createMockContainer(with files: [String: String], containerExtension: String) throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let uniqueZipName = "\(UUID().uuidString).\(containerExtension)"
        let zipURL = tempDir.appendingPathComponent(uniqueZipName)

        do {
            let archive = try Archive(url: zipURL, accessMode: .create)
            for (fileName, fileContent) in files {
                let fileData = fileContent.data(using: .utf8)
                guard let fileData else {
                    preconditionFailure("Unable to get file data")
                }
                try archive.addEntry(
                    with: fileName,
                    type: .file,
                    uncompressedSize: Int64(fileData.count),
                    compressionMethod: .deflate,
                    provider: { position, size -> Data in
                        let positionInt = Int(position)
                        let sizeInt = Int(size)
                        return fileData.subdata(in: positionInt..<positionInt + sizeInt)
                    }
                )
            }
        }

        return zipURL
    }
}
