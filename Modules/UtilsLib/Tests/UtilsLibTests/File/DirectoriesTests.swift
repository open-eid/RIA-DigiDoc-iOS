import Foundation
import CommonsLib
import CommonsTestShared
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
        let expectedURL = TestFileUtil.getTemporaryDirectory(subfolder: subfolder)

        let resultURL = try Directories.getTempDirectoryURL(subfolder: subfolder)

        #expect(resultURL == expectedURL)
        #expect(fileManager.fileExists(atPath: resultURL.path))

        try? fileManager.removeItem(at: expectedURL)
    }

    @Test
    func getTempDirectoryURL_doesntCreateDirectoryWhenExists() throws {
        let fileManager = FileManager.default
        let subfolder = "existingTestSubfolder"
        let existingDirectory = TestFileUtil.getTemporaryDirectory(subfolder: subfolder)

        try fileManager.createDirectory(at: existingDirectory, withIntermediateDirectories: true, attributes: nil)

        let resultURL = try Directories.getTempDirectoryURL(subfolder: subfolder)

        #expect(resultURL == existingDirectory)
        #expect(fileManager.fileExists(atPath: resultURL.path))

        try? fileManager.removeItem(at: existingDirectory)
    }

}
