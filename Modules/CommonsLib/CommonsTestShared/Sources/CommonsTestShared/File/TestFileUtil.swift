import Foundation
import CommonsLib

public class TestFileUtil {

    public init() {}

    public static func createSampleFile(name: String, withExtension ext: String, contents: String = "") -> URL {
        var tempFileDirectory: URL
        if #available(iOS 16.0, *) {
            tempFileDirectory = FileManager.default.temporaryDirectory
                .appending(path: BundleUtil.getBundleIdentifier(), directoryHint: .isDirectory)
                .appending(component: name)
                .appendingPathExtension(ext)
        } else {
            tempFileDirectory = FileManager.default.temporaryDirectory
                .appendingPathComponent(BundleUtil.getBundleIdentifier(), isDirectory: true)
                .appendingPathComponent(name, isDirectory: false)
                .appendingPathExtension(ext)
        }

        FileManager.default.createFile(atPath: tempFileDirectory.path, contents: contents.data(using: .utf8))

        return tempFileDirectory
    }
}
