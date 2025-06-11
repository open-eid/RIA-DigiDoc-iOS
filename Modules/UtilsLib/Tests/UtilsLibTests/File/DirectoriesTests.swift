import Foundation
import CommonsLib
import CommonsTestShared
import Testing
@testable import UtilsLib

struct DirectoriesTests {

    private let mockFileManager: FileManagerProtocolMock!

    init() async throws {
        await UtilsLibAssembler.shared.initialize()

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
        var mockedFileSystem: [String: [String]] = [:]

        let baseCacheURL = URL(fileURLWithPath: "/mock/cache")
        let subfolder = "ExistingFolder"
        let testFile = "ExistingFile"

        mockFileManager.urlsHandler = { directory, _ in
            guard directory == .cachesDirectory else { return [] }
            return [baseCacheURL]
        }

        mockFileManager.fileExistsAtPathHandler = { path, isDirectory in
            let exists = mockedFileSystem.keys.contains(path)
            if let dir = isDirectory {
                dir.pointee = ObjCBool(exists)
            }
            return exists
        }

        let fullDirectoryPath = baseCacheURL.appendingPathComponent(subfolder).path

        mockedFileSystem[fullDirectoryPath] = [testFile]

        mockFileManager.fileExistsAtPathHandler = { path, isDirectory in
            let exists = mockedFileSystem.keys.contains(path)
            if let dir = isDirectory {
                dir.pointee = ObjCBool(exists)
            }
            return exists
        }

        mockFileManager.fileExistsHandler = { _ in true }

        mockFileManager.contentsOfDirectoryHandler = { _ in
            mockedFileSystem[fullDirectoryPath] ?? []
        }

        let dir1 = try Directories.getCacheDirectory(subfolder: subfolder, fileManager: mockFileManager)
        let contents1 = try mockFileManager.contentsOfDirectory(atPath: dir1.path)

        #expect(mockFileManager.fileExists(atPath: dir1.path))
        #expect(contents1.count == 1 && contents1.contains(testFile))

        let dir2 = try Directories.getCacheDirectory(subfolder: subfolder, fileManager: mockFileManager)
        let contents2 = try mockFileManager.contentsOfDirectory(atPath: dir2.path)

        #expect(mockFileManager.fileExists(atPath: dir2.path))
        #expect(contents2.count == 1 && contents2.contains(testFile))

        #expect(mockFileManager.createDirectoryCallCount == 0)
    }
}
