import Foundation
import OSLog
import LibdigidocLibSwift
import Testing
import UtilsLib
import CommonsLib
import CommonsTestShared
import CommonsLibMocks
import UtilsLibMocks
import LibdigidocLibSwiftMocks

@MainActor
struct SigningViewModelTests {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "SigningViewModelTests")

    private let mockSharedContainerViewModel: SharedContainerViewModelProtocolMock!
    private let viewModel: SigningViewModel!
    private let mockFileManager: FileManagerProtocolMock!
    private let mockContainerUtil: ContainerUtilProtocolMock!

    init() async throws {
        mockFileManager = FileManagerProtocolMock()
        mockSharedContainerViewModel = SharedContainerViewModelProtocolMock()
        mockContainerUtil = ContainerUtilProtocolMock()

        viewModel = SigningViewModel(
            sharedContainerViewModel: mockSharedContainerViewModel,
            fileManager: mockFileManager
        )
    }

    @Test
    func loadContainerData_successWithNewFile() async throws {
        let signedContainer = SignedContainerProtocolMock()
        let dataFileWrapper = DataFileWrapper(
            fileId: "1",
            fileName: "container.asice",
            fileSize: 123,
            mediaType: CommonsLib.Constants.MimeType.Asice
        )

        let signatureWrapper = SignatureWrapper(
            signingCert: Data(),
            timestampCert: Data(),
            ocspCert: Data(),
            signatureId: "S1",
            claimedSigningTime: "1970-01-01T00:00:00Z",
            signatureMethod: "signature-method",
            ocspProducedAt: "1970-01-01T00:00:00Z",
            timeStampTime: "1970-01-01T00:00:00Z",
            signedBy: "Test User",
            trustedSigningTime: "1970-01-01T00:00:00Z",
            format: "BES/time-stamp",
            messageImprint: Data(),
            diagnosticsInfo: ""
        )

        signedContainer.getDataFilesHandler = { [dataFileWrapper] }
        signedContainer.getSignaturesHandler = { [signatureWrapper] }

        let containerDataFiles = await signedContainer.getDataFiles()
        let containerSignatures = await signedContainer.getSignatures()

        await viewModel.loadContainerData(signedContainer: signedContainer)

        let dataFiles = viewModel.dataFiles
        let signatures = viewModel.signatures

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

        mockFileManager.urlHandler = { _, _, _, _ in tempFolderURL }
        mockFileManager.fileExistsHandler = { _ in false }
        mockFileManager.copyItemHandler = { _, _ in }

        let result = viewModel.createCopyOfContainerForSaving(containerURL: containerFile)

        guard let copyURL = result else {
            Issue.record("Expected copy URL but got nil")
            return
        }

        #expect(copyURL.isFileURL)
        #expect(mockFileManager.copyItemCallCount == 1)
        #expect(mockFileManager.copyItemArgValues.first?.srcURL == containerFile)
        #expect(mockFileManager.copyItemArgValues.first?.dstURL == copyURL)
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

        mockFileManager.urlHandler = { _, _, _, _ in tempFolderURL }
        mockFileManager.fileExistsHandler = { path in
            return cacheDirectory.path == path
        }
        mockFileManager.copyItemHandler = { _, _ in }

        let result = viewModel.createCopyOfContainerForSaving(containerURL: containerFile)

        guard let copyURL = result else {
            Issue.record("Expected copy URL but got nil")
            return
        }

        #expect(copyURL.isFileURL)
        #expect(mockFileManager.copyItemCallCount == 1)
        #expect(mockFileManager.copyItemArgValues.first?.srcURL == containerFile)
        #expect(mockFileManager.copyItemArgValues.first?.dstURL == copyURL)
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

    @Test
    func renameContainer_success() async {
        let expectedURL = URL(fileURLWithPath: "/tmp/renamed.asice")

        let signedContainer = SignedContainerProtocolMock()

        signedContainer.renameContainerHandler = { _ in expectedURL }

        viewModel.signedContainer = signedContainer

        let result = await viewModel.renameContainer(to: "renamed.asice")

        #expect(result == expectedURL)
        #expect(viewModel.errorMessage == nil)
    }

    @Test
    func renameContainer_throwContainerRenamingFailedErrorAndSetLocalizedErrorMessage() async throws {
        let fileName = "test.asice"
        let signedContainer = SignedContainerProtocolMock()

        signedContainer.renameContainerHandler = { _ in
            throw DigiDocError.containerRenamingFailed(
                ErrorDetail(message: "Error", userInfo: ["fileName": fileName])
            )
        }

        viewModel.signedContainer = signedContainer

        let result = await viewModel.renameContainer(to: "no:name")

        guard let error = viewModel.errorMessage else {
            Issue.record("Expected error message to not be empty")
            return
        }

        #expect(result == nil)
        #expect(error.contains(fileName))
    }

    @Test
    func renameContainer_throwUnknownDigiDocErrorAndSetGeneralError() async {
        let signedContainer = SignedContainerProtocolMock()
        signedContainer.renameContainerHandler = { _ in
            throw DigiDocError.addingFilesToContainerFailed(ErrorDetail(message: "Some other error"))
        }

        viewModel.signedContainer = signedContainer

        let result = await viewModel.renameContainer(to: "no:name")

        #expect(result == nil)
        #expect(viewModel.errorMessage == "General error")
    }

    @Test
    func renameContainer_nonDigiDocError_setsGeneralError() async {
        let signedContainer = SignedContainerProtocolMock()
        signedContainer.renameContainerHandler = { _ in
            throw NSError(domain: "OtherError", code: 123)
        }

        viewModel.signedContainer = signedContainer

        let result = await viewModel.renameContainer(to: "Some name")

        #expect(result == nil)
        #expect(viewModel.errorMessage == "General error")
    }
}
