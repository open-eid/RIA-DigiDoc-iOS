import Foundation
import OSLog
import LibdigidocLibSwift
import Testing
import UtilsLib
import CommonsLib
import CommonsTestShared

@MainActor
struct SigningViewModelTests {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "SigningViewModelTests")

    private let mockSharedContainerViewModel: SharedContainerViewModelProtocolMock!
    private let viewModel: SigningViewModel!
    private let mockFileManager: FileManagerProtocolMock!

    init() async throws {
        mockFileManager = FileManagerProtocolMock()
        mockSharedContainerViewModel = SharedContainerViewModelProtocolMock()
        viewModel = SigningViewModel(
            sharedContainerViewModel: mockSharedContainerViewModel,
            fileManager: mockFileManager
        )
    }

    @Test
    func loadContainerData_successWithNewFile() async throws {
        let tempFile = TestFileUtil.createSampleFile()

        let signedContainer = try await SignedContainer.openOrCreate(
            dataFiles: [tempFile]
        )

        let containerDataFiles = await signedContainer.getDataFiles()
        let containerSignatures = await signedContainer.getSignatures()

        await viewModel.loadContainerData(signedContainer: signedContainer)

        let dataFiles = viewModel.dataFiles
        let signatures = viewModel.signatures

        defer {
            try? FileManager.default.removeItem(at: tempFile)
        }

        #expect(containerDataFiles.count == dataFiles.count)
        #expect(containerSignatures.count == signatures.count)
    }

    // Enable when its possible to get configuration data from test website
    @Test(.disabled())
    func loadContainerData_successWithExistingContainer() async throws {
        let containerFile = TestFileUtil.pathForResourceFile(fileName: "example", ext: "asice")

        guard let exampleContainer = containerFile else {
            Issue.record("Unable to get resource file")
            return
        }

        let signedContainer = try await SignedContainer.openOrCreate(
            dataFiles: [exampleContainer]
        )

        let containerDataFiles = await signedContainer.getDataFiles()
        let containerSignatures = await signedContainer.getSignatures()

        await viewModel.loadContainerData(signedContainer: signedContainer)

        let dataFiles = viewModel.dataFiles
        let signatures = viewModel.signatures

        #expect(containerDataFiles.count == dataFiles.count)
        #expect(containerSignatures.count == signatures.count)
    }

    @Test
    func loadContainerData_returnEmptyValuesWhenSignedContainerNil() async {
        await viewModel.loadContainerData(signedContainer: nil)

        let dataFiles = viewModel.dataFiles
        let signatures = viewModel.signatures

        #expect(dataFiles.isEmpty)
        #expect(signatures.isEmpty)
    }

    @Test
    func createCopyOfContainerForSaving_success() async throws {
        let tempFolderURL = URL(fileURLWithPath: "/tmp")

        let testFileName = "testfile.asice"
        let cacheDirectory = tempFolderURL
            .appendingPathComponent(BundleUtil.getBundleIdentifier())
            .appendingPathComponent(Constants.Folder.SavedFiles)
        let containerFile = cacheDirectory
            .appendingPathComponent(testFileName)
        let sampleData = Data("Sample data".utf8)

        var mockFileSystem: [URL: Data] = [containerFile: sampleData]

        mockFileManager.urlHandler = { _, _, _, _ in tempFolderURL }

        mockFileManager.fileExistsHandler = { _ in false }

        mockFileManager.copyItemHandler = { src, dst in
            guard let data = mockFileSystem[src] else {
                throw NSError(domain: NSCocoaErrorDomain,
                        code: NSFileNoSuchFileError,
                        userInfo: [NSLocalizedDescriptionKey: "The file at path \(src) does not exist."]
                )
            }
            mockFileSystem[dst] = data
        }

        let result = viewModel.createCopyOfContainerForSaving(containerURL: containerFile)

        guard let copyURL = result else {
            Issue.record("Expected copy URL but got nil")
            return
        }

        #expect(copyURL.isFileURL)
        #expect(mockFileSystem[copyURL] == sampleData)
    }

    @Test
    func createCopyOfContainerForSaving_returnNilWithNilContainerURL() async {
        let fileCopy = viewModel.createCopyOfContainerForSaving(containerURL: nil)
        #expect(fileCopy == nil)
    }

    @Test
    func createCopyOfContainerForSaving_returnNilWhenFileDoesNotExist() async {
        let testDirectory = URL(string: "/mock/path")
        let nonExistentFile = testDirectory?.appendingPathComponent("nonexistent.asice")

        mockFileManager.urlHandler = { _, _, _, _ in URL(fileURLWithPath: "") }

        mockFileManager.fileExistsHandler = { _ in false }

        mockFileManager.copyItemHandler = { src, _ in
            throw NSError(domain: NSCocoaErrorDomain,
                    code: NSFileNoSuchFileError,
                    userInfo: [NSLocalizedDescriptionKey: "The file at path \(src) does not exist."]
            )
        }

        let fileCopy = viewModel.createCopyOfContainerForSaving(containerURL: nonExistentFile)

        #expect(fileCopy == nil)
    }

    @Test
    func createCopyOfContainerForSaving_replaceExistingFile() async throws {
        let tempFolderURL = URL(fileURLWithPath: "/tmp")

        let testFileName = "testfile.asice"
        let cacheDirectory = tempFolderURL
            .appendingPathComponent(BundleUtil.getBundleIdentifier())
            .appendingPathComponent(Constants.Folder.SavedFiles)
        let containerFile = cacheDirectory
            .appendingPathComponent(testFileName)
        let sampleData = Data("Sample data".utf8)

        var mockFileSystem: [URL: Data] = [containerFile: sampleData]

        mockFileManager.urlHandler = { _, _, _, _ in
            return tempFolderURL
        }

        mockFileManager.fileExistsHandler = { path in
            return cacheDirectory.path == path
        }

        mockFileManager.removeItemHandler = { url in
            mockFileSystem.removeValue(forKey: url)
        }

        mockFileManager.copyItemHandler = { src, dst in
            guard let data = mockFileSystem[src] else {
                throw NSError(domain: NSCocoaErrorDomain,
                        code: NSFileNoSuchFileError,
                        userInfo: [NSLocalizedDescriptionKey: "The file at path \(src) does not exist."]
                )
            }
            mockFileSystem[dst] = data
        }

        let result = viewModel.createCopyOfContainerForSaving(containerURL: containerFile)

        guard let copyURL = result else {
            Issue.record("Expected copy URL but got nil")
            return
        }

        #expect(copyURL.isFileURL)
        #expect(mockFileSystem[copyURL] == sampleData)
    }

    @Test
    func checkIfContainerFileExists_returnTrueIfFileExists() async throws {
        let testDirectory = URL(fileURLWithPath: "/tmp")
        let testFile = testDirectory.appendingPathComponent("testFile.asice")

        mockFileManager.fileExistsHandler = { _ in true }

        let containerFileExists = viewModel.checkIfContainerFileExists(fileLocation: testFile)
        #expect(containerFileExists)
    }

    @Test
    func checkIfContainerFileExists_returnFalseIfFileDoesNotExist() async throws {
        let testDirectory = URL(fileURLWithPath: "/tmp")
        let nonExistentFile = testDirectory.appendingPathComponent("nonExistent.asice")

        mockFileManager.fileExistsHandler = { _ in false }

        let containerFileExists = viewModel.checkIfContainerFileExists(fileLocation: nonExistentFile)
        #expect(!containerFileExists)
    }

    @Test
    func checkIfContainerFileExists_returnFalseWithNilInput() async {
        let containerFileExists = viewModel.checkIfContainerFileExists(fileLocation: nil)
        #expect(!containerFileExists)
    }

    @Test
    func removeSavedFilesDirectory_successWhenDirectoryExists() async throws {
        let testDirectory = URL(fileURLWithPath: "/tmp")
        let savedFilesDirectory = testDirectory.appendingPathComponent(Constants.Folder.SavedFiles)

        mockFileManager.fileExistsHandler = { path in
            return path == savedFilesDirectory.path
        }

        #expect(mockFileManager.fileExists(atPath: savedFilesDirectory.path))

        viewModel.removeSavedFilesDirectory(savedFilesDirectory: savedFilesDirectory)

        #expect(mockFileManager.removeItemCallCount == 1)
    }

    @Test
    func removeSavedFilesDirectory_doesNotThrowErrorWhenRemovingDirectoryAndItDoesntExist() async {
        let testDirectory = URL(fileURLWithPath: "/tmp")
        let nonExistentDirectory = testDirectory.appendingPathComponent("NonExistentDir")

        #expect(throws: Never.self) {
            self.viewModel.removeSavedFilesDirectory(savedFilesDirectory: nonExistentDirectory)
        }

        #expect(!mockFileManager.fileExists(atPath: nonExistentDirectory.path))
    }
}
