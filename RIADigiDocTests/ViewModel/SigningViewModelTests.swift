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

    private let mockSharedContainerViewModel: SharedContainerViewModelProtocolMock
    private let viewModel: SigningViewModel
    private let mockFileManager: FileManagerProtocolMock
    private let mockContainerUtil: ContainerUtilProtocolMock
    private let mockFileUtil: FileUtilProtocolMock
    private let mockFileOpeningService: FileOpeningServiceProtocolMock
    private let mockMimeTypeCache: MimeTypeCacheProtocolMock
    private let mimeTypeDecoder: MimeTypeDecoderProtocolMock
    private let mockSivaRepository: SivaRepositoryProtocolMock

    init() async throws {
        mockFileManager = FileManagerProtocolMock()
        mockSharedContainerViewModel = SharedContainerViewModelProtocolMock()
        mockContainerUtil = ContainerUtilProtocolMock()
        mockFileUtil = FileUtilProtocolMock()
        mockFileOpeningService = FileOpeningServiceProtocolMock()
        mockMimeTypeCache = MimeTypeCacheProtocolMock()
        mimeTypeDecoder = MimeTypeDecoderProtocolMock()
        mockSivaRepository = SivaRepositoryProtocolMock()

        viewModel = SigningViewModel(
            sharedContainerViewModel: mockSharedContainerViewModel,
            fileOpeningService: mockFileOpeningService,
            mimeTypeCache: mockMimeTypeCache,
            mimeTypeDecoder: mimeTypeDecoder,
            fileUtil: mockFileUtil,
            fileManager: mockFileManager,
            sivaRepository: mockSivaRepository
        )
    }

    @Test
    func loadContainerData_successWithNewFile() async throws {
        let signedContainer = SignedContainerProtocolMock()

        let dataFileWrapper = MockDataFileWrapper.mockDataFileWrapper(
            fileId: "1",
            fileName: "container.asice",
            fileSize: 123,
            mediaType: CommonsLib.Constants.MimeType.Asice
        )

        let signatureWrapper = MockSignatureWrapper.mockSignatureWrapper()

        signedContainer.getDataFilesHandler = { [dataFileWrapper] }
        signedContainer.getSignaturesHandler = { [signatureWrapper] }

        #expect(viewModel.dataFiles.isEmpty)
        #expect(viewModel.signatures.isEmpty)

        await viewModel.loadContainerData(signedContainer: signedContainer)

        let dataFiles = viewModel.dataFiles
        let signatures = viewModel.signatures

        #expect(dataFiles.count == 1)
        #expect(dataFiles.first?.fileName == "container.asice")

        #expect(signatures.count == 1)
        #expect(signatures.first?.signatureId == "S1")
    }

    @Test
    func loadContainerData_successWithExistingContainer() async throws {
        let mockSignedContainer = SignedContainerProtocolMock()

        let newDataFileWrapper = MockDataFileWrapper.mockDataFileWrapper(
            fileId: "2",
            fileName: "newfile.asice",
            fileSize: 456,
            mediaType: CommonsLib.Constants.MimeType.Asice
        )

        let newSignatureWrapper = MockSignatureWrapper.mockSignatureWrapper(signatureId: "S2")

        mockSignedContainer.getDataFilesHandler = { [newDataFileWrapper] }
        mockSignedContainer.getSignaturesHandler = { [newSignatureWrapper] }

        viewModel.dataFiles = [
            MockDataFileWrapper.mockDataFileWrapper(
                fileId: "1",
                fileName: "oldfile.asice",
                fileSize: 100,
                mediaType: "application/vnd.asice"
            )
        ]

        viewModel.signatures = [ MockSignatureWrapper.mockSignatureWrapper() ]

        #expect(viewModel.dataFiles.count == 1)
        #expect(viewModel.dataFiles.first?.fileName == "oldfile.asice")

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)

        let dataFiles = viewModel.dataFiles
        let signatures = viewModel.signatures

        // Verify old data was replaced
        #expect(dataFiles.count == 1)
        #expect(dataFiles.first?.fileName == "newfile.asice")

        #expect(signatures.count == 1)
        #expect(signatures.first?.signatureId == "S2")
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

        let mockSignedContainer = SignedContainerProtocolMock()
        mockSignedContainer.renameContainerHandler = { _ in expectedURL }

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)

        let result = await viewModel.renameContainer(to: "renamed.asice")

        #expect(result == expectedURL)
        #expect(viewModel.errorMessage == nil)
    }

    @Test
    func renameContainer_throwContainerRenamingFailedErrorAndSetLocalizedErrorMessage() async throws {
        let fileName = "test.asice"
        let mockSignedContainer = SignedContainerProtocolMock()

        mockSignedContainer.renameContainerHandler = { _ in
            throw DigiDocError.containerRenamingFailed(
                ErrorDetail(message: "Error", userInfo: ["fileName": fileName])
            )
        }

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)

        let result = await viewModel.renameContainer(to: "no:name")

        guard let (errorKey, args) = viewModel.errorMessage else {
            Issue.record("Expected error message to not be empty")
            return
        }

        #expect(result == nil)
        #expect(!errorKey.isEmpty)
        #expect(args.contains(fileName))
    }

    @Test
    func renameContainer_throwUnknownDigiDocErrorAndSetGeneralError() async {
        let mockSignedContainer = SignedContainerProtocolMock()
        mockSignedContainer.renameContainerHandler = { _ in
            throw DigiDocError.addingFilesToContainerFailed(ErrorDetail(message: "Some other error"))
        }

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)

        let result = await viewModel.renameContainer(to: "no:name")

        guard let (errorKey, args) = viewModel.errorMessage else {
            Issue.record("Expected error message to not be empty")
            return
        }

        #expect(result == nil)
        #expect(errorKey == "General error")
        #expect(args == [])
    }

    @Test
    func renameContainer_nonDigiDocError_setsGeneralError() async {
        let mockSignedContainer = SignedContainerProtocolMock()
        mockSignedContainer.renameContainerHandler = { _ in
            throw NSError(domain: "OtherError", code: 123)
        }

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)

        let result = await viewModel.renameContainer(to: "Some name")

        guard let (errorKey, args) = viewModel.errorMessage else {
            Issue.record("Expected error message to not be empty")
            return
        }

        #expect(result == nil)
        #expect(errorKey == "General error")
        #expect(args == [])
    }

    @Test
    func handleFileOpening_successSettingPreviewFileForRegularFile() async throws {
        let mockSignedContainer = SignedContainerProtocolMock()

        let testFile = URL(fileURLWithPath: "/tmp/test.txt")

        let mimeType = CommonsLib.Constants.MimeType.Default

        let testDataFile = MockDataFileWrapper.mockDataFileWrapper(
            fileId: "1",
            fileName: testFile.lastPathComponent,
            fileSize: 123,
            mediaType: mimeType
        )

        mockMimeTypeCache.getMimeTypeHandler = { _ in mimeType }

        mockFileOpeningService.openOrCreateContainerHandler = { _, _ in mockSignedContainer }

        mockSignedContainer.saveDataFileHandler = { _, _ in testFile }

        mockFileUtil.fileExistsHandler = { _ in true }

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)

        await viewModel.handleFileOpening(dataFile: testDataFile, isSivaConfirmed: true)

        #expect(viewModel.previewFile?.lastPathComponent == "test.txt")
        #expect(viewModel.errorMessage == nil)
    }

    @Test
    func handleFileOpening_successOpeningNestedContainer() async throws {
        let mockSignedContainer = SignedContainerProtocolMock()
        let mockNestedSignedContainer = SignedContainerProtocolMock()

        let testFile = URL(fileURLWithPath: "/tmp/test.txt")

        let mimeType = CommonsLib.Constants.MimeType.Asice

        let testDataFile = MockDataFileWrapper.mockDataFileWrapper(
            fileId: "1",
            fileName: testFile.lastPathComponent,
            fileSize: 123,
            mediaType: mimeType
        )

        mockSignedContainer.getContainerNameHandler = { "mockSignedContainer.asice" }
        mockNestedSignedContainer.getContainerNameHandler = { "mockNestedSignedContainer.asice" }

        mockMimeTypeCache.getMimeTypeHandler = { _ in mimeType }

        mockFileOpeningService.openOrCreateContainerHandler = { _, _ in mockNestedSignedContainer }

        mockSignedContainer.saveDataFileHandler = { _, _ in testFile }

        mockFileUtil.fileExistsHandler = { _ in true }

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)

        let currentSignedContainerName = await viewModel.signedContainer?.getContainerName()
        let mockSignedContainerName = await mockSignedContainer.getContainerName()

        // Check that current container is the main container (not nested)
        #expect(currentSignedContainerName == mockSignedContainerName)

        mockSharedContainerViewModel.currentContainerHandler = { mockNestedSignedContainer }

        await viewModel.handleFileOpening(dataFile: testDataFile, isSivaConfirmed: true)

        let updatedSignedContainerName = await viewModel.signedContainer?.getContainerName()
        let mockNestedSignedContainerName = await mockNestedSignedContainer.getContainerName()

        #expect(viewModel.previewFile == nil)
        #expect(viewModel.errorMessage == nil)

        // Check that current container is nested container (not main)
        #expect(updatedSignedContainerName == mockNestedSignedContainerName)
    }

    @Test
    func handleFileOpening_throwErrorWhenSettingPreviewFileForRegularFile() async throws {
        let mockSignedContainer = SignedContainerProtocolMock()

        let testFile = URL(fileURLWithPath: "/tmp/test.txt")

        let mimeType = CommonsLib.Constants.MimeType.Default

        let testDataFile = MockDataFileWrapper.mockDataFileWrapper(
            fileId: "1",
            fileName: testFile.lastPathComponent,
            fileSize: 123,
            mediaType: mimeType
        )

        mockSignedContainer.saveDataFileHandler = { _, _ in
            throw DigiDocError.containerDataFileSavingFailed(
                ErrorDetail(
                    message: "Unable to save datafile",
                    code: 0,
                    userInfo: ["fileName": testFile.lastPathComponent]
                ))
        }

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)

        await viewModel.handleFileOpening(dataFile: testDataFile, isSivaConfirmed: true)

        guard let (errorKey, args) = viewModel.errorMessage else {
            Issue.record("Expected error message to not be empty")
            return
        }

        #expect(viewModel.previewFile == nil)
        #expect(errorKey == "Failed to open file")
        #expect(args == [testDataFile.fileName])
    }

    @Test
    func handleFileOpening_throwErrorWhenOpeningNestedContainer() async throws {
        let mockSignedContainer = SignedContainerProtocolMock()

        let testFile = URL(fileURLWithPath: "/tmp/test.txt")

        let mimeType = CommonsLib.Constants.MimeType.Asice

        let testDataFile = MockDataFileWrapper.mockDataFileWrapper(
            fileId: "1",
            fileName: testFile.lastPathComponent,
            fileSize: 123,
            mediaType: mimeType
        )

        mockMimeTypeCache.getMimeTypeHandler = { _ in mimeType }

        mockSignedContainer.saveDataFileHandler = { _, _ in testFile }

        mockFileUtil.fileExistsHandler = { _ in true }

        mockFileOpeningService.openOrCreateContainerHandler = { _, _ in
            throw DigiDocError.containerOpeningFailed(
                ErrorDetail(
                    message: "Cannot open container. Container file is nil"))
        }

        mockSignedContainer.getContainerNameHandler = { "mockSignedContainer.asice" }

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)

        await viewModel.handleFileOpening(dataFile: testDataFile, isSivaConfirmed: true)

        guard let (errorKey, args) = viewModel.errorMessage else {
            Issue.record("Expected error message to not be empty")
            return
        }

        let currentSignedContainerName = await viewModel.signedContainer?.getContainerName()
        let mockSignedContainerName = await mockSignedContainer.getContainerName()

        #expect(viewModel.previewFile == nil)
        #expect(errorKey == "Failed to open container")
        #expect(args == [testDataFile.fileName])
        #expect(currentSignedContainerName == mockSignedContainerName)
    }

    @Test
    func handleFileOpening_cancelOpeningContainerWhenDdocCancel() async throws {
        let mockSignedContainer = SignedContainerProtocolMock()

        let testFile = URL(fileURLWithPath: "/tmp/mockSignedContainer.ddoc")

        let mimeType = CommonsLib.Constants.MimeType.Ddoc

        let testDataFile = MockDataFileWrapper.mockDataFileWrapper(
            fileId: "1",
            fileName: testFile.lastPathComponent,
            fileSize: 123,
            mediaType: mimeType
        )

        mockMimeTypeCache.getMimeTypeHandler = { _ in mimeType }

        mockSignedContainer.saveDataFileHandler = { _, _ in testFile }

        mockFileUtil.fileExistsHandler = { _ in true }

        mockFileOpeningService.openOrCreateContainerHandler = { _, _ in
            throw DigiDocError.containerOpeningFailed(
                ErrorDetail(
                    message: "Cannot open container. Container file is nil"))
        }

        mockSignedContainer.getContainerNameHandler = { "mockSignedContainer.ddoc" }

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)

        await viewModel.handleFileOpening(dataFile: testDataFile, isSivaConfirmed: false)

        #expect(mockFileOpeningService.openOrCreateContainerCallCount == 0)
        #expect(mockMimeTypeCache.getMimeTypeCallCount == 1)
    }

    @Test
    func handleSaveFile_success() async throws {
        let testFile = URL(fileURLWithPath: "/tmp/test.txt")
        let mockSignedContainer = SignedContainerProtocolMock()

        let testDataFile = MockDataFileWrapper.mockDataFileWrapper(
            fileName: testFile.lastPathComponent,
            mediaType: CommonsLib.Constants.MimeType.Default
        )

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)
        mockSignedContainer.saveDataFileHandler = { _, _ in testFile }
        mockFileUtil.fileExistsHandler = { _ in true }

        await viewModel.handleSaveFile(dataFile: testDataFile)

        #expect(viewModel.selectedDataFile == testFile)
        #expect(viewModel.isShowingFileSaver == true)
        #expect(viewModel.errorMessage == nil)
    }

    @Test
    func handleSaveFile_throwErrorWhenSavingDataFile() async throws {
        let testFile = URL(fileURLWithPath: "/tmp/test.txt")
        let mockSignedContainer = SignedContainerProtocolMock()

        let testDataFile = MockDataFileWrapper.mockDataFileWrapper(
            fileName: testFile.lastPathComponent,
            mediaType: CommonsLib.Constants.MimeType.Default
        )

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)

        mockSignedContainer.saveDataFileHandler = { _, _ in
            throw DigiDocError.containerDataFileSavingFailed(
                ErrorDetail(
                    message: "Unable to save datafile",
                    code: 0,
                    userInfo: ["fileName": testFile.lastPathComponent]
                ))
        }

        await viewModel.handleSaveFile(dataFile: testDataFile)

        guard let (errorKey, args) = viewModel.errorMessage else {
            Issue.record("Expected error message to not be empty")
            return
        }

        #expect(viewModel.selectedDataFile == nil)
        #expect(viewModel.isShowingFileSaver == false)
        #expect(errorKey == "Failed to save file")
        #expect(args == [testFile.lastPathComponent])
    }

    @Test
    func isSivaConfirmationNeeded_returnTrue() async throws {
        let mockSignedContainer = SignedContainerProtocolMock()

        let testFile = URL(fileURLWithPath: "/tmp/mockSignedContainer.asics")

        let mimeType = CommonsLib.Constants.MimeType.Asics

        let testDataFile = MockDataFileWrapper.mockDataFileWrapper(
            fileName: testFile.lastPathComponent,
            mediaType: mimeType
        )

        mockMimeTypeCache.getMimeTypeHandler = { _ in mimeType }

        mockSignedContainer.saveDataFileHandler = { _, _ in testFile }

        mockFileUtil.fileExistsHandler = { _ in true }

        mockSignedContainer.getContainerNameHandler = { "mockSignedContainer.asics" }

        mockSivaRepository.isSivaConfirmationNeededHandler = { _ in true }

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)

        let isSivaConfirmationNeeded = await viewModel.isSivaConfirmationNeeded(dataFile: testDataFile)

        #expect(isSivaConfirmationNeeded)
    }

    @Test
    func isSivaConfirmationNeeded_returnFalse() async throws {
        let mockSignedContainer = SignedContainerProtocolMock()

        let testFile = URL(fileURLWithPath: "/tmp/mockSignedContainer.asice")

        let mimeType = CommonsLib.Constants.MimeType.Asice

        let testDataFile = MockDataFileWrapper.mockDataFileWrapper(
            fileName: testFile.lastPathComponent,
            mediaType: mimeType
        )

        mockMimeTypeCache.getMimeTypeHandler = { _ in mimeType }

        mockSignedContainer.saveDataFileHandler = { _, _ in testFile }

        mockFileUtil.fileExistsHandler = { _ in false }

        mockSignedContainer.getContainerNameHandler = { "mockSignedContainer.asice" }

        mockSivaRepository.isSivaConfirmationNeededHandler = { _ in true }

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)

        let isSivaConfirmationNeeded = await viewModel.isSivaConfirmationNeeded(dataFile: testDataFile)

        #expect(!isSivaConfirmationNeeded)
    }

    @Test
    func isSivaConfirmationNeeded_returnFalseWhenDataFileSavingDidNotSucceed() async throws {
        let mockSignedContainer = SignedContainerProtocolMock()

        let testFile = URL(fileURLWithPath: "/tmp/mockSignedContainer.asice")

        let mimeType = CommonsLib.Constants.MimeType.Asice

        let testDataFile = MockDataFileWrapper.mockDataFileWrapper(
            fileName: testFile.lastPathComponent,
            mediaType: mimeType
        )

        mockMimeTypeCache.getMimeTypeHandler = { _ in mimeType }

        mockSignedContainer.saveDataFileHandler = { _, _ in testFile }

        mockFileUtil.fileExistsHandler = { _ in false }

        mockSignedContainer.getContainerNameHandler = { "mockSignedContainer.asice" }

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)

        let isSivaConfirmationNeeded = await viewModel.isSivaConfirmationNeeded(dataFile: testDataFile)

        #expect(!isSivaConfirmationNeeded)
        #expect(mockSivaRepository.isSivaConfirmationNeededCallCount == 0)
    }

    @Test
    func isNestedContainer_returnTrue() async {
        mockSharedContainerViewModel.isNestedContainerHandler = { _ in true }

        let isNestedContainer = viewModel.isNestedContainer()

        #expect(isNestedContainer)
    }

    @Test
    func isNestedContainer_returnFalse() async {
        mockSharedContainerViewModel.isNestedContainerHandler = { _ in false }

        let isNestedContainer = viewModel.isNestedContainer()

        #expect(!isNestedContainer)
    }

    @Test
    func isSignButtonShown_returnTrueWithSignableContainer() async {
        let container = SignedContainerProtocolMock()
        container.getContainerMimetypeHandler = { Constants.MimeType.Asice }
        container.getContainerNameHandler = { "mockContainer.asice" }

        let isSignButtonShown = await viewModel.isSignButtonShown(
            signedContainer: container,
            isNestedContainer: false
        )

        #expect(isSignButtonShown)
    }

    @Test
    func isSignButtonShown_returnFalseWithUnsignableContainer() async {
        let container = SignedContainerProtocolMock()
        container.getContainerMimetypeHandler = { Constants.MimeType.Ddoc }
        container.getContainerNameHandler = { "mockContainer.ddoc" }

        let isSignButtonShown = await viewModel.isSignButtonShown(
            signedContainer: container,
            isNestedContainer: false
        )

        #expect(!isSignButtonShown)
    }

    @Test
    func isSignButtonShown_returnFalseWithNestedContainer() async {
        let container = SignedContainerProtocolMock()
        container.getContainerMimetypeHandler = { Constants.MimeType.Asics }
        container.getContainerNameHandler = { "mockContainer.asice" }

        let isSignButtonShown = await viewModel.isSignButtonShown(
            signedContainer: container,
            isNestedContainer: true
        )

        #expect(!isSignButtonShown)
    }

    @Test
    func isSignButtonShown_returnFalseWhenContainerIsNil() async {
        let isSignButtonShown = await viewModel.isSignButtonShown(
            signedContainer: nil,
            isNestedContainer: false
        )

        #expect(!isSignButtonShown)
    }

    @Test
    func isEncryptButtonShown_returnTrueWithExistingContainer() async {
        let mockSignedContainer = SignedContainerProtocolMock()
        mockSignedContainer.isExistingContainerHandler = { true }

        mockSignedContainer.getSignaturesHandler = { [] }

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)

        let isEncryptButtonShown = await viewModel.isEncryptButtonShown(
            signedContainer: mockSignedContainer,
            isNestedContainer: false
        )

        #expect(isEncryptButtonShown)
    }

    @Test
    func isEncryptButtonShown_returnTrueWithSignedContainer() async {
        let mockSignedContainer = SignedContainerProtocolMock()
        mockSignedContainer.isExistingContainerHandler = { false }

        mockSignedContainer.getSignaturesHandler = {
            [MockSignatureWrapper.mockSignatureWrapper()]
        }

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)

        let isEncryptButtonShown = await viewModel.isEncryptButtonShown(
            signedContainer: mockSignedContainer,
            isNestedContainer: false
        )

        #expect(isEncryptButtonShown)
    }

    @Test
    func isEncryptButtonShown_notSignedOrExisting_returnFalseWhenContainerIsNotSignedOrExisting() async {
        let mockSignedContainer = SignedContainerProtocolMock()
        mockSignedContainer.isExistingContainerHandler = { false }
        mockSignedContainer.getSignaturesHandler = { [] }

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)

        let isEncryptButtonShown = await viewModel.isEncryptButtonShown(
            signedContainer: mockSignedContainer,
            isNestedContainer: false
        )

        #expect(!isEncryptButtonShown)
    }

    @Test
    func isEncryptButtonShown_returnFalseWithNestedContainer() async {
        let mockSignedContainer = SignedContainerProtocolMock()

        mockSignedContainer.isExistingContainerHandler = { true }
        mockSignedContainer.getSignaturesHandler = {
            [MockSignatureWrapper.mockSignatureWrapper()]
        }

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)

        let isEncryptButtonShown = await viewModel.isEncryptButtonShown(
            signedContainer: mockSignedContainer,
            isNestedContainer: true
        )

        #expect(!isEncryptButtonShown)
    }

    @Test
    func isEncryptButtonShown_returnFalseIfContainerNil() async {
        let mockSignedContainer = SignedContainerProtocolMock()

        mockSignedContainer.getSignaturesHandler = {
            [MockSignatureWrapper.mockSignatureWrapper()]
        }

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)

        let isEncryptButtonShown = await viewModel.isEncryptButtonShown(
            signedContainer: nil,
            isNestedContainer: false
        )

        #expect(!isEncryptButtonShown)
    }

    @Test
    func isTimestampedContainer_returnFalseIfContainerIsNil() async {
        let isTimestampedContainer = await viewModel.isTimestampedContainer()
        #expect(!isTimestampedContainer)
        #expect(mockSivaRepository.isTimestampedContainerCallCount == 0)
    }

    @Test
    func isTimestampedContainer_returnTrue() async {
        let container = SignedContainerProtocolMock()
        mockSivaRepository.isTimestampedContainerHandler = { _ in true }

        await viewModel.loadContainerData(signedContainer: container)

        let isTimestampedContainer = await viewModel.isTimestampedContainer()

        #expect(isTimestampedContainer)
        #expect(mockSivaRepository.isTimestampedContainerCallCount == 2)
        #expect(mockSivaRepository.isTimestampedContainerArgValues.first === container)
    }

    @Test
    func isTimestampedContainer_returnFalse() async {
        let container = SignedContainerProtocolMock()
        mockSivaRepository.isTimestampedContainerHandler = { _ in false }

        await viewModel.loadContainerData(signedContainer: container)

        let isTimestampedContainer = await viewModel.isTimestampedContainer()

        #expect(!isTimestampedContainer)
        #expect(mockSivaRepository.isTimestampedContainerCallCount == 2)
    }

    @Test
    func getContainerNotifications_returnEmptyFileNotification() async {
        let mockSignedContainer = SignedContainerProtocolMock()
        mockSignedContainer.isEmptyFileInContainerHandler = { true }

        let notifications = await viewModel.getContainerNotifications(container: mockSignedContainer)

        #expect(notifications.count == 1)
        #expect(notifications.first == .emptyFile)
    }

    @Test
    func getContainerNotifications_returnUnsupportedContainerNotification() async {
        let mockSignedContainer = SignedContainerProtocolMock()
        mockSignedContainer.isEmptyFileInContainerHandler = {
            return false
        }
        mockFileUtil.getMimeTypeFromZipFileHandler = { _, _ in
            return Constants.MimeType.Ddoc
        }
        mockSignedContainer.getRawContainerFileHandler = {
            URL(fileURLWithPath: "/mock/path/mockContainer.ddoc")
        }

        let notifications = await viewModel.getContainerNotifications(container: mockSignedContainer)

        #expect(notifications.count == 1)
        #expect(notifications.first == .unsupportedContainer)
    }

    @Test
    func getContainerNotifications_returnUnknownSignaturesNotification() async {
        let mockSignedContainer = SignedContainerProtocolMock()
        mockSignedContainer.isEmptyFileInContainerHandler = { false }
        mockSignedContainer.getSignaturesStatusCountHandler = { [.unknown: 5, .invalid: 0] }

        let notifications = await viewModel.getContainerNotifications(container: mockSignedContainer)

        #expect(notifications.count == 1)
        #expect(notifications.first == .unknownSignatures(count: 5))
    }

    @Test
    func getContainerNotifications_returnInvalidSignaturesNotification() async {
        let mockSignedContainer = SignedContainerProtocolMock()
        mockSignedContainer.isEmptyFileInContainerHandler = { false }
        mockSignedContainer.getSignaturesStatusCountHandler = { [.unknown: 0, .invalid: 3] }

        let notifications = await viewModel.getContainerNotifications(container: mockSignedContainer)

        #expect(notifications.count == 1)
        #expect(notifications.first == .invalidSignatures(count: 3))
    }

    @Test
    func getContainerNotifications_returnMultipleConditionsNotifications() async {
        let mockSignedContainer = SignedContainerProtocolMock()
        mockSignedContainer.isEmptyFileInContainerHandler = { true }
        mockSignedContainer.getSignaturesStatusCountHandler = { [.unknown: 2, .invalid: 3] }
        mockFileUtil.getMimeTypeFromZipFileHandler = { _, _ in
            return Constants.MimeType.Ddoc
        }
        mockSignedContainer.getRawContainerFileHandler = {
            URL(fileURLWithPath: "/mock/path/mockContainer.ddoc")
        }

        let notifications = await viewModel.getContainerNotifications(container: mockSignedContainer)

        #expect(notifications.count == 4)
        #expect(notifications ==
                [
                    .emptyFile,
                    .unsupportedContainer,
                    .unknownSignatures(count: 2),
                    .invalidSignatures(count: 3)
                ]
        )
    }
}
