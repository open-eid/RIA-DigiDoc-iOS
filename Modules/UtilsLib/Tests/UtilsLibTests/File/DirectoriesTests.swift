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
    func getTempDirectory_createDirectory() throws {
        let fileManager = FileManager.default
        let subfolder = "testSubfolder"
        let expectedURL = TestFileUtil.getTemporaryDirectory(subfolder: subfolder)

        let resultURL = try Directories.getTempDirectory(subfolder: subfolder)

        #expect(resultURL == expectedURL)
        #expect(fileManager.fileExists(atPath: resultURL.path))

        try? fileManager.removeItem(at: expectedURL)
    }

    @Test
    func getTempDirectory_doesntCreateDirectoryWhenExists() throws {
        let fileManager = FileManager.default
        let subfolder = "existingTestSubfolder"
        let existingDirectory = TestFileUtil.getTemporaryDirectory(subfolder: subfolder)

        try fileManager.createDirectory(at: existingDirectory, withIntermediateDirectories: true, attributes: nil)

        let resultURL = try Directories.getTempDirectory(subfolder: subfolder)

        #expect(resultURL == existingDirectory)
        #expect(fileManager.fileExists(atPath: resultURL.path))

        try? fileManager.removeItem(at: existingDirectory)
    }

    @Test
    func getSharedFolder_returnCorrectURLWhenFolderExists() throws {
        guard let sharedContainerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: Constants.Identifier.Group
        ) else {
            Issue.record("Expected valid shared container URL")
            return
        }

        let testSubFolder = "TestFolder-\(UUID().uuidString)"
        let expectedFolderURL = sharedContainerURL.appendingPathComponent(testSubFolder)
        try FileManager.default.createDirectory(at: expectedFolderURL, withIntermediateDirectories: true)

        defer {
            try? FileManager.default.removeItem(at: expectedFolderURL)
        }

        let result = try Directories.getSharedFolder(
            subfolder: testSubFolder
        )

        #expect(expectedFolderURL.standardizedFileURL == result.standardizedFileURL)
        #expect(FileManager.default.fileExists(atPath: result.path))
    }

    @Test
    func getSharedFolder_createAndReturnCorrectURLWhenFolderDoesNotExist() throws {
        guard let sharedContainerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: Constants.Identifier.Group
        ) else {
            Issue.record("Expected valid shared container URL")
            return
        }

        let testSubFolder = "TestFolder-\(UUID().uuidString)"
        let expectedFolderURL = sharedContainerURL.appendingPathComponent(testSubFolder)

        defer {
            try? FileManager.default.removeItem(at: expectedFolderURL)
        }

        let result = try Directories.getSharedFolder(
            subfolder: testSubFolder
        )

        #expect(expectedFolderURL.standardizedFileURL == result.standardizedFileURL)
        #expect(FileManager.default.fileExists(atPath: result.path))
    }

    @Test
    func getSharedFolder_throwErrorWhenContainerURLDoesNotExist() {

        let emptyAppGroupIdentifier = ""

        do {
            _ = try Directories.getSharedFolder(appGroupIdentifier: emptyAppGroupIdentifier)
            Issue.record("Expected .fileDoesNotExist error")
            return
        } catch let error as URLError {
            #expect(error.code == .fileDoesNotExist)
        } catch {
            Issue.record("Expected .fileDoesNotExist error")
            return
        }
    }
}
