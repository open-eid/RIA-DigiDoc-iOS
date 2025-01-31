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

    @Test
    func getCacheDirectory_returnCorrectPath() throws {
        let subfolder = "TestFolder-\(UUID().uuidString)"

        let directory = try Directories.getCacheDirectory(subfolder: subfolder)

        let expectedBaseDir = try FileManager.default.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ).appendingPathComponent(BundleUtil.getBundleIdentifier(), isDirectory: true)

        let expectedDir = expectedBaseDir.appendingPathComponent(subfolder, isDirectory: true)

        defer {
            try? FileManager.default.removeItem(at: directory)
        }

        #expect(expectedDir == directory)
    }

    @Test
    func getCacheDirectory_createDirectoryIfNotExists() throws {
        let subfolder = "NewTestFolder-\(UUID().uuidString)"
        let testDir = try Directories.getCacheDirectory(subfolder: subfolder)

        #expect(FileManager.default.fileExists(atPath: testDir.path))

        try FileManager.default.removeItem(at: testDir)
    }

    @Test
    func getCacheDirectory_returnDirectoryWithoutSubfolder() throws {
        let directory = try Directories.getCacheDirectory()

        let expectedDir = try FileManager.default.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ).appendingPathComponent(BundleUtil.getBundleIdentifier(), isDirectory: true)

        #expect(expectedDir == directory)
    }

    @Test
    func getCacheDirectory_doesNotRecreateExistingDirectory() throws {
        let subfolder = "ExistingFolder-\(UUID().uuidString)"
        let testFile = "ExistingFile-\(UUID().uuidString)"
        let testDir = try Directories.getCacheDirectory(subfolder: subfolder)

        try FileManager.default.createDirectory(at: testDir, withIntermediateDirectories: true, attributes: nil)
        try "Test file contents".write(to: testDir.appendingPathComponent(testFile), atomically: true, encoding: .utf8)

        let testDirContents = try FileManager.default.contentsOfDirectory(atPath: testDir.path)
        #expect(FileManager.default.fileExists(atPath: testDir.path))
        #expect(!testDirContents.isEmpty && testDirContents.count == 1)

        let directory = try Directories.getCacheDirectory(subfolder: subfolder)

        let cacheDirContents = try FileManager.default.contentsOfDirectory(atPath: directory.path)

        #expect(FileManager.default.fileExists(atPath: directory.path))
        #expect(!cacheDirContents.isEmpty && cacheDirContents.count == 1)

        try FileManager.default.removeItem(at: directory)
    }
}
