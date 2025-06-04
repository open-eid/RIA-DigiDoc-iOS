import Foundation
import Testing
import CommonsLib
import CommonsTestShared
import ZIPFoundation
@testable import UtilsLib

struct FileUtilTests {

    private static let testSubFolder = "FileUtilTests"

    private let fileUtil: FileUtilProtocol!

    init() async throws {
        await UtilsLibAssembler.shared.initialize()

        let tempDir = TestFileUtil.getTemporaryDirectory(subfolder: FileUtilTests.testSubFolder)
        try? FileManager.default.removeItem(at: tempDir)

        fileUtil = FileUtil()
    }

    @Test
    func getMimeTypeFromZipFile_returnCorrectMimeType() async throws {
        let asiceMimetype = CommonsLib.Constants.MimeType.Asice
        let zipFileURL = try TestContainerUtil.createMockContainer(
            with: ["mimetype": asiceMimetype],
            containerExtension: "zip")

        defer {
            try? FileManager.default.removeItem(at: zipFileURL)
        }

        let fileNameToFind = "mimetype"

        let mimeType = try await fileUtil.getMimeTypeFromZipFile(from: zipFileURL, fileNameToFind: fileNameToFind)

        #expect(asiceMimetype == mimeType)
    }

    @Test
    func getMimeTypeFromZipFile_returnNilWhenFileDoesNotExist() async throws {
        let zipFileURL = try TestContainerUtil.createMockContainer(
            with: [:],
            containerExtension: "zip")

        let fileNameToFind = "nonexistentfile.txt"

        let mimeType = try await fileUtil.getMimeTypeFromZipFile(from: zipFileURL, fileNameToFind: fileNameToFind)

        #expect(mimeType == nil)

        try FileManager.default.removeItem(at: zipFileURL)
    }

    @Test
    func getValidFileInApp_returnFileURLWhenFileExistsInAppDirectory() throws {
        let fileURL = TestFileUtil.createSampleFile()

        defer {
            try? FileManager.default.removeItem(at: fileURL)
        }

        let result = try fileUtil.getValidFileInApp(currentURL: fileURL)

        #expect(fileURL.resolvingSymlinksInPath() == result)
    }

    @Test
    func getValidFileInApp_returnNilWhenFileNotInDirectories() throws {
        let nonExistentFileURL = URL(fileURLWithPath: "someFolder")

        let result = try fileUtil.getValidFileInApp(currentURL: nonExistentFileURL)

        #expect(result == nil)
    }

    @Test
    func getValidFileInApp_ContinueSearchAndReturnSameDirectoryURLWhenDirectoryAccessFails() throws {
        let testDirectory = TestFileUtil.getTemporaryDirectory(subfolder: "FileUtilTests")
        let nonExistentDirectory = testDirectory.appendingPathComponent("NonExistent-\(UUID().uuidString)")

        defer {
            try? FileManager.default.removeItem(at: testDirectory)
        }

        let result = try fileUtil.getValidFileInApp(currentURL: nonExistentDirectory)

        #expect(nonExistentDirectory.resolvingSymlinksInPath() == result)
    }

    @Test
    func isFileFromAppGroup_returnTrueWhenFileInsideAppGroup() async throws {

        let appGroupFolder = try Directories.getSharedFolder()
        let fileInAppGroup = appGroupFolder.appendingPathComponent("file.txt")

        try FileManager.default.createDirectory(at: appGroupFolder, withIntermediateDirectories: true)
        try "Test Data".write(to: fileInAppGroup, atomically: true, encoding: .utf8)

        defer {
            try? FileManager.default.removeItem(at: fileInAppGroup)
            try? FileManager.default.removeItem(at: appGroupFolder)
        }

        let result = try fileUtil.isFileFromAppGroup(url: fileInAppGroup, appGroupURL: appGroupFolder)

        #expect(result)
    }

    @Test
    func isFileFromAppGroup_returnFalseWhenFileOutsideAppGroup() throws {
        let appGroupFolder = try Directories.getSharedFolder()
        let fileOutsideAppGroup = FileManager.default.temporaryDirectory.appendingPathComponent("OutsideFile.txt")

        try FileManager.default.createDirectory(at: appGroupFolder, withIntermediateDirectories: true)
        try "Test Data".write(to: fileOutsideAppGroup, atomically: true, encoding: .utf8)

        defer {
            try? FileManager.default.removeItem(at: fileOutsideAppGroup)
            try? FileManager.default.removeItem(at: appGroupFolder)
        }

        let result = try fileUtil.isFileFromAppGroup(
            url: fileOutsideAppGroup, appGroupURL: nil
        )

        #expect(!result)
    }
}
