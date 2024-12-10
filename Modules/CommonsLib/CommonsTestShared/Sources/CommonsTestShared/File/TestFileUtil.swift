import Foundation
import OSLog
import CommonsLib

public class TestFileUtil {

    private static let logger = Logger(
        subsystem: "ee.ria.digidoc.CommonsLib.CommonsTestShared",
        category: "TestFileUtil"
    )

    private static let bundleIdentifier =  Bundle.main.bundleIdentifier ?? "ee.ria.digidoc"

    public init() {}

    public static func getTemporaryDirectory(subfolder: String) -> URL {
        var tempDirectory: URL
        if #available(iOS 16.0, *) {
            tempDirectory = FileManager.default.temporaryDirectory
                .appending(path: bundleIdentifier, directoryHint: .isDirectory)
                .appending(path: subfolder, directoryHint: .isDirectory)
        } else {
            tempDirectory = FileManager.default.temporaryDirectory
                .appendingPathComponent(bundleIdentifier, isDirectory: true)
                .appendingPathComponent(subfolder, isDirectory: true)
        }

        do {
            if !FileManager.default.fileExists(atPath: tempDirectory.path) {
                try FileManager.default.createDirectory(
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
        subfolder: String = "TestFileUtil"
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

        let isCreated = FileManager.default
            .createFile(
                atPath: tempFileDirectory.path,
                contents: contents?.data(
                    using: .utf8
                )
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
