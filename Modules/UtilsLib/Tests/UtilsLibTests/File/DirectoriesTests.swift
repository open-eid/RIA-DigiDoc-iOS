import Foundation
import Testing
import CommonsLib
import CommonsTestShared
import CommonsLibMocks

@testable import UtilsLib

struct DirectoriesTests {

    private let mockFileManager: FileManagerProtocolMock!

    private var testLibraryDirectory: URL!
    private var testCacheDirectory: URL!

    init() async throws {
        mockFileManager = FileManagerProtocolMock()
    }

    @Test
    func getTempDirectory_createDirectory() async throws {
        let tempDirectory = URL(fileURLWithPath: "/tmp")
        let subfolder = "testSubfolder"
        let expectedURL = tempDirectory
            .appendingPathComponent(BundleUtil.getBundleIdentifier())
            .appendingPathComponent(subfolder)

        mockFileManager.temporaryDirectory = tempDirectory
        mockFileManager.fileExistsHandler = { _ in false }

        let resultURL = try Directories.getTempDirectory(subfolder: subfolder, fileManager: mockFileManager)

        #expect(resultURL.path == expectedURL.path)
        #expect(mockFileManager.createDirectoryCallCount == 1)
    }

    @Test
    func getTempDirectory_doesntCreateDirectoryWhenExists() async throws {
        let tempDirectory = URL(fileURLWithPath: "/tmp")
        let subfolder = "existingTestSubfolder"
        let expectedURL = tempDirectory
            .appendingPathComponent(BundleUtil.getBundleIdentifier())
            .appendingPathComponent(subfolder)

        mockFileManager.temporaryDirectory = tempDirectory
        mockFileManager.fileExistsHandler = { _ in true }

        let resultURL = try Directories.getTempDirectory(subfolder: subfolder, fileManager: mockFileManager)

        #expect(resultURL.path == expectedURL.path)
        #expect(mockFileManager.createDirectoryCallCount == 0)
    }

    @Test
    func getSharedFolder_returnCorrectURLWhenFolderExists() async throws {
        guard let sharedContainerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: Constants.Identifier.Group
        ) else {
            Issue.record("Expected valid shared container URL")
            return
        }

        let testSubFolder = "TestFolder"
        let expectedFolderURL = sharedContainerURL.appendingPathComponent(testSubFolder)

        mockFileManager.containerURLHandler = { _ in sharedContainerURL }
        mockFileManager.fileExistsHandler = { _ in true }

        let result = try Directories.getSharedFolder(
            subfolder: testSubFolder,
            fileManager: mockFileManager
        )

        #expect(expectedFolderURL.standardizedFileURL == result.standardizedFileURL)
        #expect(mockFileManager.createDirectoryCallCount == 0)
    }

    @Test
    func getSharedFolder_createAndReturnCorrectURLWhenFolderDoesNotExist() async throws {
        guard let sharedContainerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: Constants.Identifier.Group
        ) else {
            Issue.record("Expected valid shared container URL")
            return
        }

        let testSubFolder = "TestFolder-\(UUID().uuidString)"
        let expectedFolderURL = sharedContainerURL.appendingPathComponent(testSubFolder)

        mockFileManager.containerURLHandler = { _ in sharedContainerURL }
        mockFileManager.fileExistsHandler = { _ in false }

        let result = try Directories.getSharedFolder(
            subfolder: testSubFolder,
            fileManager: mockFileManager
        )

        #expect(expectedFolderURL.standardizedFileURL == result.standardizedFileURL)
        #expect(mockFileManager.createDirectoryCallCount == 1)
    }

    @Test
    func getSharedFolder_throwErrorWhenContainerURLDoesNotExist() async {

        let emptyAppGroupIdentifier = ""

        mockFileManager.containerURLHandler = { _ in nil }

        do {
            _ = try Directories.getSharedFolder(appGroupIdentifier: emptyAppGroupIdentifier,
                                                fileManager: mockFileManager)
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
    func getCacheDirectory_returnCorrectPath() async throws {
        let cacheDirectory = URL(fileURLWithPath: "/cache")
        let subfolder = "TestFolder"
        let expectedDir = cacheDirectory
            .appendingPathComponent(BundleUtil.getBundleIdentifier())
            .appendingPathComponent(subfolder, isDirectory: true)

        mockFileManager.urlHandler = { _, _, _, _ in cacheDirectory }
        mockFileManager.fileExistsHandler = { _ in true }

        let directory = try Directories.getCacheDirectory(subfolder: subfolder, fileManager: mockFileManager)

        #expect(expectedDir == directory)
        #expect(mockFileManager.createDirectoryCallCount == 0)
    }

    @Test
    func getCacheDirectory_createDirectoryIfNotExists() async throws {
        let cacheDirectory = URL(fileURLWithPath: "/cache")
        let subfolder = "NewTestFolder"
        let expectedDir = cacheDirectory
            .appendingPathComponent(BundleUtil.getBundleIdentifier())
            .appendingPathComponent(subfolder, isDirectory: true)

        mockFileManager.urlHandler = { _, _, _, _ in cacheDirectory }
        mockFileManager.fileExistsHandler = { _ in false }

        let directory = try Directories.getCacheDirectory(subfolder: subfolder, fileManager: mockFileManager)

        #expect(expectedDir == directory)
        #expect(mockFileManager.createDirectoryCallCount == 1)
    }

    @Test
    func getCacheDirectory_returnDirectoryWithoutSubfolder() async throws {
        let cacheDirectory = URL(fileURLWithPath: "/cache")
        let expectedDir = cacheDirectory
            .appendingPathComponent(BundleUtil.getBundleIdentifier())

        mockFileManager.urlHandler = { _, _, _, _ in cacheDirectory }
        mockFileManager.fileExistsHandler = { _ in true }

        let directory = try Directories.getCacheDirectory(fileManager: mockFileManager)

        #expect(expectedDir.path == directory.path)
        #expect(mockFileManager.createDirectoryCallCount == 0)
    }

    @Test
    func getCacheDirectory_doesNotRecreateExistingDirectory() async throws {
        let baseCacheURL = URL(fileURLWithPath: "/mock/cache")
        let existingFolderURL = baseCacheURL
            .appendingPathComponent(BundleUtil.getBundleIdentifier(), isDirectory: true)
            .appendingPathComponent("existingFolder")

        mockFileManager.urlHandler = { _, _, _, _ in
            return baseCacheURL
        }

        mockFileManager.fileExistsHandler = { path in
            return path == existingFolderURL.path
        }

        let result = try Directories.getCacheDirectory(
            subfolder: "existingFolder",
            fileManager: mockFileManager
        )

        #expect(result.path == existingFolderURL.path)
        #expect(mockFileManager.createDirectoryCallCount == 0)
    }

    @Test
    func getLibraryDirectory_success() async throws {
        let mockDirectory = URL(fileURLWithPath: "mock/library/directory")

        mockFileManager.urlsHandler = { _, _ in
            return [URL(fileURLWithPath: "mock/library/directory")]
        }

        let directory = Directories.getLibraryDirectory(fileManager: mockFileManager)

        #expect(mockDirectory == directory)
    }

    @Test
    func getLogsDirectory_primaryDirectoryExists() throws {
        let mockDirectory = URL(fileURLWithPath: "/path/to/primary/directory")
        let expectedDirectory = mockDirectory.appendingPathComponent("logs")

        let trimmedExpectedDirectoryPath = expectedDirectory.path.hasPrefix("/") ? String(
            expectedDirectory.path.dropFirst()
        ) : expectedDirectory.path

        mockFileManager.fileExistsHandler = { _ in true }

        mockFileManager.createDirectoryHandler = { _, _, _ in }

        let logFilePath = try Directories.getLibdigidocLogFile(
            from: mockDirectory,
            fileManager: mockFileManager
        )

        let trimmedLogFilePath = expectedDirectory.path.hasPrefix("/") ? String(
            expectedDirectory.path.dropFirst()
        ) : expectedDirectory.path

        #expect(logFilePath != nil)
        #expect(trimmedExpectedDirectoryPath == trimmedLogFilePath)
        #expect("libdigidocpp.log" == logFilePath?.lastPathComponent)
    }

    @Test
    func getLogsDirectory_mainDirectoryDoesNotExistButFallbackDirectoryExists() async throws {

        mockFileManager.fileExistsHandler = { _ in false }

        let logFilePath = try Directories.getLibdigidocLogFile(from: nil, fileManager: mockFileManager)

        #expect(logFilePath != nil)
        #expect("libdigidocpp.log" == logFilePath?.lastPathComponent)
    }
}
