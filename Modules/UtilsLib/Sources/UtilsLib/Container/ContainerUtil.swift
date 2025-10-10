import Foundation
import OSLog
import FactoryKit
import CommonsLib

public struct ContainerUtil: ContainerUtilProtocol {

    private static let logger = Logger(subsystem: "ee.ria.digidoc.UtilsLib", category: "ContainerUtil")

    private let dataFileDirectory = "%@-data-files"

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

    public func getSignatureContainersDir() throws -> URL {
        let cachesDirectory = try fileManager.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false)
        let signedContainersDirectory = cachesDirectory.appendingPathComponent(
            Constants.Container.SignedContainerFolder,
            isDirectory: true
        )

        do {
            try fileManager
                .createDirectory(at: signedContainersDirectory, withIntermediateDirectories: true, attributes: [:])
            ContainerUtil.logger.debug("Directories created or already exist for \(signedContainersDirectory.path)")
        } catch {
            ContainerUtil.logger.error("Unable to create signature containers dir: \(error.localizedDescription)")
            throw error
        }

        return signedContainersDirectory
    }

    public func getContainerDataFilesDir(
        containerFile: URL?
    ) throws -> URL {
        let signatureDir = try getSignatureContainersDir()
        let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first

        if containerFile?.deletingLastPathComponent() == signatureDir {
            return createDataFileDirectory(
                directory: cacheDir,
                container: containerFile
            )
        } else {
            return createDataFileDirectory(
                directory: containerFile?.deletingLastPathComponent(),
                container: containerFile
            )
        }
    }

    private func createDataFileDirectory(
        directory: URL?,
        container: URL?
    ) -> URL {
        var index = 0
        let baseDirectory = directory ?? URL(fileURLWithPath: "")

        while true {
            var dirName = String(format: dataFileDirectory, container?.lastPathComponent ?? "")
            if index > 0 {
                dirName.append("\(index)")
            }

            let targetDirectory = baseDirectory.appendingPathComponent(dirName, isDirectory: true)

            var isDirectory: ObjCBool = false
            let exists = fileManager.fileExists(atPath: targetDirectory.path, isDirectory: &isDirectory)

            if !exists || isDirectory.boolValue {
                do {
                    try fileManager.createDirectory(
                        at: targetDirectory,
                        withIntermediateDirectories: true,
                        attributes: [:]
                    )
                    if let base = directory {
                        ContainerUtil.logger.debug("Directories created or already exist for \(base.path)")
                    }
                } catch {
                    ContainerUtil.logger.error("Failed to create directory: \(error.localizedDescription)")
                }

                return targetDirectory
            }

            index += 1
        }
    }
}
