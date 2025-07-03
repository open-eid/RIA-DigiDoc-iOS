import Foundation
import FactoryKit
import UtilsLib
import CommonsLib

public struct TSLUtil {

    public static func setupTSLFiles(tsls: [String] = [], destinationDir: URL, fileManager: FileManagerProtocol) throws {
        let tslFiles = !tsls.isEmpty ? tsls : Bundle.module.paths(
            forResourcesOfType: "xml",
            inDirectory: CommonsLib.Constants.Configuration.TslFilesFolder
        )

        try createDirectoryIfNotExist(at: destinationDir, fileManager: fileManager)

        for filePath in tslFiles {
            let fileName = (filePath as NSString).lastPathComponent

            if isXMLFile(
                fileName
            ), shouldCopyTSL(
                from: filePath,
                to: destinationDir.appendingPathComponent(
                    fileName
                ).path,
                fileManager: fileManager
            ) {
                try copyTSL(from: filePath, to: destinationDir.appendingPathComponent(fileName).path)
                try removeExistingETag(
                    at: destinationDir.appendingPathComponent(
                        fileName
                    ).path,
                    fileManager: fileManager
                )
            }
        }
    }

    private static func isXMLFile(_ filename: String) -> Bool {
        return filename.hasSuffix(".xml")
    }

    private static func shouldCopyTSL(
        from sourcePath: String,
        to destinationPath: String,
        fileManager: FileManagerProtocol
    ) -> Bool {
        if !fileManager.fileExists(atPath: destinationPath) {
            return true
        } else {
            do {
                let assetURL = URL(fileURLWithPath: sourcePath)
                let cachedURL = URL(fileURLWithPath: destinationPath)

                let assetsTSLVersion = try readSequenceNumber(from: assetURL)
                let cachedTSLVersion = try readSequenceNumber(from: cachedURL)

                return assetsTSLVersion > cachedTSLVersion
            } catch {
                return false
            }
        }
    }

    private static func copyTSL(from sourcePath: String, to destinationPath: String) throws {
        let data = try Data(contentsOf: URL(fileURLWithPath: sourcePath))
        try data.write(to: URL(fileURLWithPath: destinationPath))
    }

    private static func removeExistingETag(
        at filePath: String,
        fileManager: FileManagerProtocol
    ) throws {
        let eTagURL = URL(fileURLWithPath: filePath).appendingPathExtension("etag")
        if fileManager.fileExists(atPath: eTagURL.path) {
            try fileManager.removeItem(atPath: eTagURL.path)
        }
    }

    private static func readSequenceNumber(from inputStreamURL: URL) throws -> Int {
        let parser = XMLParser(contentsOf: inputStreamURL)
        let tslSequenceNumberElement = "TSLSequenceNumber"

        var sequenceNumber: Int?

        let delegate = TSLParserDelegate(sequenceNumberElement: tslSequenceNumberElement)
        parser?.delegate = delegate

        if parser?.parse() == true, let foundSequenceNumber = delegate.foundSequenceNumber {
            sequenceNumber = foundSequenceNumber
        }

        if let sequenceNumber = sequenceNumber {
            return sequenceNumber
        } else {
            throw TSLUtilError.sequenceNumberError(message: "Error reading version from TSL")
        }
    }

    private static func createDirectoryIfNotExist(
        at url: URL,
        fileManager: FileManagerProtocol
    ) throws {
        if !fileManager.fileExists(atPath: url.path) {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
    }
}
