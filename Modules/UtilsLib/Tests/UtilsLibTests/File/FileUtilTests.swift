import Foundation
import Testing
import FactoryKit
import FactoryTesting
import ZIPFoundation
import CommonsLib
import CommonsTestShared
import CommonsLibMocks

@testable import UtilsLib

struct FileUtilTests {

    private let mockFileManager: FileManagerProtocolMock
    private let fileUtil: FileUtilProtocol

    init() async throws {
        self.mockFileManager = FileManagerProtocolMock()
        self.fileUtil = FileUtil(fileManager: mockFileManager)
    }

    @Test(.container)
    func getMimeTypeFromZipFile_returnCorrectMimeType() async throws {
        let asiceMimetype = CommonsLib.Constants.MimeType.Asice
        let zipFileURL = try TestContainerUtil.createMockContainer(
            with: ["mimetype": asiceMimetype],
            containerExtension: "zip")

        defer {
            try? FileManager.default.removeItem(at: zipFileURL)
        }

        let fileNameToFind = "mimetype"


        let fileUtil = FileUtil(fileManager: Container.shared.fileManager())
        let mimeType = try await fileUtil.getMimeTypeFromZipFile(
            from: zipFileURL,
            fileNameToFind: fileNameToFind
        )

        #expect(asiceMimetype == mimeType)
    }

    @Test
    func getMimeTypeFromZipFile_returnNilWhenFileDoesNotExist() async throws {
        let zipFileURL = try TestContainerUtil.createMockContainer(
            with: [:],
            containerExtension: "zip")

        let fileNameToFind = "nonexistentfile.txt"

        let mimeType = try await fileUtil.getMimeTypeFromZipFile(
            from: zipFileURL,
            fileNameToFind: fileNameToFind
        )

        #expect(mimeType == nil)

        try FileManager.default.removeItem(at: zipFileURL)
    }

    @Test
    func getValidFileInApp_returnFileURLWhenFileExistsInAppDirectory() async throws {
        let fileURL = URL(fileURLWithPath: mockFileManager.temporaryDirectory.resolvingSymlinksInPath().path + "/tmp")

        guard let sharedContainerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: Constants.Identifier.Group
        ) else {
            Issue.record("Expected valid shared container URL")
            return
        }

        mockFileManager.urlsHandler = { _, _ in [fileURL] }
        mockFileManager.containerURLHandler = { _ in sharedContainerURL }
        mockFileManager.contentsOfDirectoryAtHandler = { _, _, _ in [fileURL] }

        let result = try fileUtil.getValidFileInApp(currentURL: fileURL)

        #expect(fileURL.resolvingSymlinksInPath() == result)
    }

    @Test
    func getValidFileInApp_returnNilWhenFileNotInDirectories() async throws {
        let nonExistentFileURL = URL(fileURLWithPath: "someFolder")

        let result = try fileUtil.getValidFileInApp(currentURL: nonExistentFileURL)

        #expect(result == nil)
    }

    @Test
    func getValidFileInApp_ContinueSearchAndReturnSameDirectoryURLWhenDirectoryAccessFails() async throws {
        let testDirectory = URL(fileURLWithPath:
                                    mockFileManager.temporaryDirectory.resolvingSymlinksInPath().path + "/tmp")
        let fileURL = testDirectory.appendingPathComponent("testFile.txt")
        let nonExistentDirectory = testDirectory.appendingPathComponent("NonExistent-\(UUID().uuidString)")

        mockFileManager.urlsHandler = { _, _ in [testDirectory] }
        mockFileManager.contentsOfDirectoryAtHandler = { _, _, _ in [fileURL] }

        let result = try fileUtil.getValidFileInApp(currentURL: nonExistentDirectory)

        #expect(nonExistentDirectory.resolvingSymlinksInPath() == result)
    }

    @Test
    func isFileFromAppGroup_returnTrueWhenFileInsideAppGroup() async throws {

        mockFileManager.containerURLHandler = { _ in
            FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: Constants.Identifier.Group
            )
        }

        mockFileManager.fileExistsHandler = { _ in true }

        let appGroupFolder = try Directories.getSharedFolder(fileManager: mockFileManager)
        let fileInAppGroup = appGroupFolder.appendingPathComponent("file.txt")

        let result = try fileUtil.isFileFromAppGroup(url: fileInAppGroup, appGroupURL: appGroupFolder)

        #expect(result)
    }

    @Test
    func isFileFromAppGroup_returnFalseWhenFileOutsideAppGroup() async throws {
        let mockFileUrl = URL(fileURLWithPath: "/data/example/Documents/file.txt")
        let mockAppGroupUrl = URL(fileURLWithPath: "/data/example/Library/GroupContainers/group.com.example")

        mockFileManager.containerURLHandler = { _ in mockFileUrl }
        mockFileManager.fileExistsHandler = { _ in true }

        let result = try fileUtil.isFileFromAppGroup(
            url: mockFileUrl, appGroupURL: mockAppGroupUrl
        )

        #expect(!result)
    }
}
