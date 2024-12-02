import Foundation
import CommonsLib
import Testing
import Cuckoo
@testable import UtilsLib

final class DirectoriesTests {

    init() async throws {
        await UtilsLibAssembler.shared.initialize()
    }

    @Test
    func getTempDirectoryURL_createDirectory() throws {
        let fileManager = FileManager.default
        let subfolder = "testSubfolder"
        var expectedURL: URL
        if #available(iOS 16.0, *) {
            expectedURL = fileManager.temporaryDirectory
                .appending(path: BundleUtil.getBundleIdentifier(), directoryHint: .isDirectory)
                .appending(path: subfolder, directoryHint: .isDirectory)
        } else {
            expectedURL = fileManager.temporaryDirectory
                .appendingPathComponent(BundleUtil.getBundleIdentifier(), isDirectory: true)
                .appendingPathComponent(subfolder, isDirectory: true)
        }

        let resultURL = try Directories.getTempDirectoryURL(subfolder: subfolder)

        #expect(resultURL == expectedURL)
        #expect(fileManager.fileExists(atPath: resultURL.path))

        try? fileManager.removeItem(at: expectedURL)
    }

    @Test
    func getTempDirectoryURL_doesntCreateDirectoryWhenExists() throws {
        let fileManager = FileManager.default
        let subfolder = "existingTestSubfolder"
        var existingDirectory: URL
        if #available(iOS 16.0, *) {
            existingDirectory = fileManager.temporaryDirectory
                .appending(path: BundleUtil.getBundleIdentifier(), directoryHint: .isDirectory)
                .appending(path: subfolder, directoryHint: .isDirectory)
        } else {
            existingDirectory = fileManager.temporaryDirectory
                .appendingPathComponent(BundleUtil.getBundleIdentifier(), isDirectory: true)
                .appendingPathComponent(subfolder, isDirectory: true)
        }

        try fileManager.createDirectory(at: existingDirectory, withIntermediateDirectories: true, attributes: nil)

        let resultURL = try Directories.getTempDirectoryURL(subfolder: subfolder)

        #expect(resultURL == existingDirectory)
        #expect(fileManager.fileExists(atPath: resultURL.path))

        try? fileManager.removeItem(at: existingDirectory)
    }

}
