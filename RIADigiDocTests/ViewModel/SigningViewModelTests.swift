import Foundation
import LibdigidocLibSwift
import Testing
import Cuckoo
import UtilsLib
import CommonsLib
import CommonsTestShared

final class SigningViewModelTests {
    private var mockSharedContainerViewModel: MockSharedContainerViewModel!
    private var viewModel: SigningViewModel!
    private var fileManager: FileManager!

    init() async throws {
        fileManager = FileManager.default
        mockSharedContainerViewModel = MockSharedContainerViewModel()
        viewModel = await SigningViewModel(sharedContainerViewModel: mockSharedContainerViewModel)
    }

    deinit {
        viewModel = nil
        mockSharedContainerViewModel = nil
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

        let dataFiles = await viewModel.dataFiles
        let signatures = await viewModel.signatures

        defer {
            try? FileManager.default.removeItem(at: tempFile)
        }

        #expect(containerDataFiles.count == dataFiles.count)
        #expect(containerSignatures.count == signatures.count)
    }

    @Test
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

        let dataFiles = await viewModel.dataFiles
        let signatures = await viewModel.signatures

        #expect(containerDataFiles.count == dataFiles.count)
        #expect(containerSignatures.count == signatures.count)
    }

    @Test
    func loadContainerData_returnEmptyValuesWhenSignedContainerNil() async {
        await viewModel.loadContainerData(signedContainer: nil)

        let dataFiles = await viewModel.dataFiles
        let signatures = await viewModel.signatures

        #expect(dataFiles.isEmpty)
        #expect(signatures.isEmpty)
    }

    func createCopyOfContainerForSaving_success() async throws {
        let testDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: testDirectory, withIntermediateDirectories: true)
        let containerFile = testDirectory.appendingPathComponent("testfile-\(UUID().uuidString).asice")
        let testData = Data("Sample data".utf8)
        fileManager.createFile(atPath: containerFile.path, contents: testData, attributes: nil)

        let fileCopy = await viewModel.createCopyOfContainerForSaving(containerURL: containerFile)

        guard let file = fileCopy else {
            Issue.record("Unable to get copy of container file")
            return
        }

        #expect(file != nil)
        #expect(fileManager.fileExists(atPath: file.path))

        try? fileManager.removeItem(at: testDirectory)
    }

    @Test
    func createCopyOfContainerForSaving_returnNilWithNilContainerURL() async {
        let fileCopy = await viewModel.createCopyOfContainerForSaving(containerURL: nil)
        #expect(fileCopy == nil)
    }

    @Test
    func createCopyOfContainerForSaving_returnNilWhenFileDoesNotExist() async {
        let testDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: testDirectory, withIntermediateDirectories: true)

        let nonExistentFile = testDirectory.appendingPathComponent("nonexistent-\(UUID().uuidString).asice")

        let fileCopy = await viewModel.createCopyOfContainerForSaving(containerURL: nonExistentFile)

        #expect(fileCopy == nil)

        try? fileManager.removeItem(at: testDirectory)
    }

    @Test
    func createCopyOfContainerForSaving_replaceExistingFile() async throws {
        let testDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: testDirectory, withIntermediateDirectories: true)

        let containerFile = testDirectory.appendingPathComponent("testfile-\(UUID().uuidString).asice")
        let testData = Data("Old Data".utf8)

        fileManager.createFile(atPath: containerFile.path, contents: testData, attributes: nil)

        let savedFilesDirectory = try Directories.getCacheDirectory(subfolder: CommonsLib.Constants.Folder.SavedFiles)
        let expectedDestination = savedFilesDirectory.appendingPathComponent(
            containerFile.lastPathComponent.sanitized()
        )

        fileManager.createFile(
            atPath: expectedDestination.path,
            contents: Data("Old content".utf8),
            attributes: nil
        )

        let fileCopy = await viewModel.createCopyOfContainerForSaving(containerURL: containerFile)

        guard let file = fileCopy else {
            Issue.record("Unable to get copy of container file")
            return
        }

        #expect(file != nil)
        #expect(fileManager.fileExists(atPath: file.path))

        let newData = try Data(contentsOf: file)
        #expect(testData == newData)

        try? fileManager.removeItem(at: expectedDestination)
        try? fileManager.removeItem(at: testDirectory)
    }

    @Test
    func checkIfContainerFileExists_returnTrueIfFileExists() async throws {
        let testDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: testDirectory, withIntermediateDirectories: true)

        let testFile = testDirectory.appendingPathComponent("testFile-\(UUID().uuidString).asice")
        fileManager.createFile(atPath: testFile.path, contents: Data(), attributes: nil)

        let containerFileExists = await viewModel.checkIfContainerFileExists(fileLocation: testFile)
        #expect(containerFileExists)

        try? fileManager.removeItem(at: testDirectory)
    }

    @Test
    func checkIfContainerFileExists_returnFalseIfFileDoesNotExist() async throws {
        let testDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: testDirectory, withIntermediateDirectories: true)

        let nonExistentFile = testDirectory.appendingPathComponent("nonExistent-\(UUID().uuidString).asice")

        let containerFileExists = await viewModel.checkIfContainerFileExists(fileLocation: nonExistentFile)
        #expect(!containerFileExists)

        try? fileManager.removeItem(at: testDirectory)
    }

    @Test
    func checkIfContainerFileExists_returnFalseWithNilInput() async {
        let containerFileExists = await viewModel.checkIfContainerFileExists(fileLocation: nil)
        #expect(!containerFileExists)
    }

    @Test
    func removeSavedFilesDirectory_successWhenDirectoryExists() async throws {
        let testDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: testDirectory, withIntermediateDirectories: true)

        let savedFilesDirectory = testDirectory.appendingPathComponent("SavedFiles")
        try fileManager.createDirectory(at: savedFilesDirectory, withIntermediateDirectories: true, attributes: nil)

        let testFile = savedFilesDirectory.appendingPathComponent("test-\(UUID().uuidString).asice")
        fileManager.createFile(atPath: testFile.path, contents: Data(), attributes: nil)

        #expect(fileManager.fileExists(atPath: savedFilesDirectory.path))

        await viewModel.removeSavedFilesDirectory(savedFilesDirectory: savedFilesDirectory)

        #expect(!fileManager.fileExists(atPath: savedFilesDirectory.path))

        try? fileManager.removeItem(at: testDirectory)
    }

    @Test
    func removeSavedFilesDirectory_doesNotThrowErrorWhenRemovingDirectoryAndItDoesntExist() async {
        let testDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: testDirectory, withIntermediateDirectories: true)

        let nonExistentDirectory = testDirectory.appendingPathComponent("NonExistentDir")

        await #expect(throws: Never.self) {
            await viewModel.removeSavedFilesDirectory(savedFilesDirectory: nonExistentDirectory)
        }

        #expect(!fileManager.fileExists(atPath: nonExistentDirectory.path))

        try? fileManager.removeItem(at: testDirectory)
    }
}
