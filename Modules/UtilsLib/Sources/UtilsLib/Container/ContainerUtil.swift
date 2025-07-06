import Foundation
import FactoryKit
import CommonsLib

public struct ContainerUtil: ContainerUtilProtocol {

    let fileManager: FileManagerProtocol

    init(fileManager: FileManagerProtocol = Container.shared.fileManager()) {
        self.fileManager = fileManager
    }

    public func getSignatureContainerFile(
        for fileURL: URL,
        in directory: URL
    ) -> URL {
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
