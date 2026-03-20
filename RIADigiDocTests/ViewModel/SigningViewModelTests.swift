/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

import Foundation
import LibdigidocLibSwift
import Testing
import UtilsLib
import CommonsLib
import CommonsTestShared
import CommonsLibMocks
import UtilsLibMocks
import LibdigidocLibSwiftMocks

@MainActor
struct SigningViewModelTests: Loggable {

    private let mockSharedContainerViewModel: SharedContainerViewModelProtocolMock
    private let viewModel: SigningViewModel
    private let mockFileManager: FileManagerProtocolMock
    private let mockFileInspector: FileInspectorProtocolMock
    private let mockContainerUtil: ContainerUtilProtocolMock
    private let mockFileUtil: FileUtilProtocolMock
    private let mockFileOpeningService: FileOpeningServiceProtocolMock
    private let mockMimeTypeCache: MimeTypeCacheProtocolMock
    private let mockMimeTypeDecoder: MimeTypeDecoderProtocolMock
    private let mockSivaRepository: SivaRepositoryProtocolMock

    init() async throws {
        mockFileManager = FileManagerProtocolMock()
        mockFileInspector = FileInspectorProtocolMock()
        mockSharedContainerViewModel = SharedContainerViewModelProtocolMock()
        mockContainerUtil = ContainerUtilProtocolMock()
        mockFileUtil = FileUtilProtocolMock()
        mockFileOpeningService = FileOpeningServiceProtocolMock()
        mockMimeTypeCache = MimeTypeCacheProtocolMock()
        mockMimeTypeDecoder = MimeTypeDecoderProtocolMock()
        mockSivaRepository = SivaRepositoryProtocolMock()

        viewModel = SigningViewModel(
            sharedContainerViewModel: mockSharedContainerViewModel,
            fileOpeningService: mockFileOpeningService,
            mimeTypeCache: mockMimeTypeCache,
            mimeTypeDecoder: mockMimeTypeDecoder,
            fileUtil: mockFileUtil,
            fileManager: mockFileManager,
            fileInspector: mockFileInspector,
            sivaRepository: mockSivaRepository,
            containerUtil: mockContainerUtil
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
            .appending(path: BundleUtil.getBundleIdentifier())
            .appending(path: Constants.Folder.SavedFiles)
        let containerFile = cacheDirectory
            .appending(path: testFileName)

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
        let nonExistentFile = testDirectory?.appending(path: "nonexistent.asice")

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
            .appending(path: BundleUtil.getBundleIdentifier())
            .appending(path: Constants.Folder.SavedFiles)
        let containerFile = cacheDirectory
            .appending(path: testFileName)

        mockFileManager.urlHandler = { _, _, _, _ in tempFolderURL }
        mockFileManager.fileExistsHandler = { path in
            return cacheDirectory.resolvedPath == path
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
        let savedFilesDirectory = testDirectory.appending(path: Constants.Folder.SavedFiles)

        viewModel.removeSavedFilesDirectory(savedFilesDirectory: savedFilesDirectory)

        #expect(mockFileUtil.removeSavedFilesDirectoryCallCount == 1)
    }

    @Test
    func removeSavedFilesDirectory_doesNotThrowErrorWhenRemovingDirectoryAndItDoesntExist() async {
        let testDirectory = URL(fileURLWithPath: "/tmp")
        let nonExistentDirectory = testDirectory.appending(path: "NonExistentDir")

        #expect(throws: Never.self) {
            self.viewModel.removeSavedFilesDirectory(savedFilesDirectory: nonExistentDirectory)
        }

        #expect(!mockFileManager.fileExists(atPath: nonExistentDirectory.resolvedPath))
    }

    @Test
    func renameContainer_success() async {
        let expectedURL = URL(fileURLWithPath: "/tmp/renamed.asice")

        let mockSignedContainer = SignedContainerProtocolMock()
        mockSignedContainer.getRawContainerFileHandler = { expectedURL }
        mockSignedContainer.renameContainerHandler = { _ in mockSignedContainer }

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)

        let result = await viewModel.renameContainer(to: expectedURL.lastPathComponent)

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

        guard let errorKey = viewModel.errorMessage?.key, let args = viewModel.errorMessage?.args else {
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

        guard let errorKey = viewModel.errorMessage?.key, let args = viewModel.errorMessage?.args else {
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

        guard let errorKey = viewModel.errorMessage?.key, let args = viewModel.errorMessage?.args else {
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
        let nestedContainerFile = TestFileUtil.pathForResourceFile(fileName: "example_no_signatures", ext: "asice")

        guard let exampleContainer = nestedContainerFile else {
            Issue.record("Unable to get resource file")
            return
        }

        let tempDirectory = try TestFileUtil.getTemporaryDirectory(
            subfolder: "SigningViewModelTests-successOpeningNestedContainer"
        )

        let localExampleContainer = tempDirectory.appending(
            path: "\(UUID().uuidString)-\(exampleContainer.lastPathComponent)",
            directoryHint: .notDirectory
        )

        try FileManager.default.copyItem(
            at: exampleContainer,
            to: localExampleContainer
        )

        let mockSignedContainer = SignedContainerProtocolMock()

        let nestedSignedContainer = try await SignedContainer.openOrCreate(
            dataFiles: [localExampleContainer],
            isSivaConfirmed: true
        )

        let mimeType = CommonsLib.Constants.MimeType.Asice

        let nestedSignedContainerFile = await nestedSignedContainer.getRawContainerFile()

        guard let nestedSignedContainerUrl = nestedSignedContainerFile else { return }

        mockSignedContainer.getContainerNameHandler = { "mockSignedContainer.asice" }

        mockMimeTypeCache.getMimeTypeHandler = { _ in mimeType }

        mockFileOpeningService.openOrCreateContainerHandler = { _, _ in nestedSignedContainer }

        mockSignedContainer.saveDataFileHandler = { _, _ in nestedSignedContainerUrl }

        mockFileUtil.fileExistsHandler = { _ in true }

        mockSharedContainerViewModel.currentContainerHandler = { mockSignedContainer }

        mockMimeTypeDecoder.parseHandler = { _ in .asice }

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)

        let currentSignedContainerName = await viewModel.signedContainer?.getContainerName()
        let mockSignedContainerName = await mockSignedContainer.getContainerName()

        // Check that current container is the main container (not nested)
        #expect(currentSignedContainerName == mockSignedContainerName)

        mockSharedContainerViewModel.currentContainerHandler = { nestedSignedContainer }

        let testDataFile = MockDataFileWrapper.mockDataFileWrapper(
            fileId: "1",
            fileName: nestedSignedContainerUrl.lastPathComponent,
            fileSize: 123,
            mediaType: mimeType
        )

        await viewModel.handleFileOpening(dataFile: testDataFile, isSivaConfirmed: true)

        let updatedSignedContainerName = await viewModel.signedContainer?.getContainerName()
        let nestedSignedContainerName = await nestedSignedContainer.getContainerName()

        #expect(viewModel.previewFile == nil)
        #expect(viewModel.errorMessage == nil)

        // Check that current container is nested container (not main)
        #expect(updatedSignedContainerName == nestedSignedContainerName)

        try? FileManager.default.removeItem(at: nestedSignedContainerUrl)
        try? FileManager.default.removeItem(at: localExampleContainer)
        try? FileManager.default.removeItem(at: tempDirectory)
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

        guard let errorKey = viewModel.errorMessage?.key, let args = viewModel.errorMessage?.args else {
            Issue.record("Expected error message to not be empty")
            return
        }

        #expect(viewModel.previewFile == nil)
        #expect(errorKey == "Failed to open file")
        #expect(args == [testDataFile.fileName])
    }

    @Test
    func handleFileOpening_throwErrorWhenOpeningNestedContainer() async throws {
        let nestedContainerFile = TestFileUtil.pathForResourceFile(fileName: "example_no_signatures", ext: "asice")

        guard let exampleContainer = nestedContainerFile else {
            Issue.record("Unable to get resource file")
            return
        }

        let tempDirectory = try TestFileUtil.getTemporaryDirectory(
            subfolder: "SigningViewModelTests-throwErrorWhenOpeningNestedContainer"
        )

        let localExampleContainer = tempDirectory.appending(
            path: "\(UUID().uuidString)-\(exampleContainer.lastPathComponent)",
            directoryHint: .notDirectory
        )

        try FileManager.default.copyItem(
            at: exampleContainer,
            to: localExampleContainer
        )

        let mockSignedContainer = SignedContainerProtocolMock()

        let nestedSignedContainer = try await SignedContainer.openOrCreate(
            dataFiles: [localExampleContainer],
            isSivaConfirmed: true
        )

        let mimeType = CommonsLib.Constants.MimeType.Asice

        let nestedSignedContainerFile = await nestedSignedContainer.getRawContainerFile()

        guard let nestedSignedContainerUrl = nestedSignedContainerFile else {
            Issue.record("Unable to get nestedSignedContainerUrl")
            return
        }

        mockSignedContainer.getContainerNameHandler = { nestedSignedContainerUrl.lastPathComponent }

        mockMimeTypeCache.getMimeTypeHandler = { _ in mimeType }

        mockFileOpeningService.openOrCreateContainerHandler = { _, _ in
            throw DigiDocError.containerOpeningFailed(
                ErrorDetail(
                    message: "Cannot open container. Container file is nil"))
        }

        mockSignedContainer.saveDataFileHandler = { _, _ in nestedSignedContainerUrl }

        mockFileUtil.fileExistsHandler = { _ in true }

        mockSharedContainerViewModel.currentContainerHandler = { mockSignedContainer }

        mockMimeTypeDecoder.parseHandler = { _ in .asice }

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)

        let currentSignedContainerName = await viewModel.signedContainer?.getContainerName()
        let mockSignedContainerName = await mockSignedContainer.getContainerName()

        // Check that current container is the main container (not nested)
        #expect(currentSignedContainerName == mockSignedContainerName)

        mockSharedContainerViewModel.currentContainerHandler = { nestedSignedContainer }

        let testDataFile = MockDataFileWrapper.mockDataFileWrapper(
            fileId: "1",
            fileName: nestedSignedContainerUrl.lastPathComponent,
            fileSize: 123,
            mediaType: mimeType
        )

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)

        await viewModel.handleFileOpening(dataFile: testDataFile, isSivaConfirmed: true)

        guard let errorKey = viewModel.errorMessage?.key, let args = viewModel.errorMessage?.args else {
            Issue.record("Expected error message to not be empty")
            return
        }

        let currentNestedSignedContainerName = await viewModel.signedContainer?.getContainerName()
        let signedNestedContainerName = await nestedSignedContainer.getContainerName()

        #expect(viewModel.previewFile == nil)
        #expect(errorKey == "Failed to open container")
        #expect(args == [testDataFile.fileName])
        #expect(currentNestedSignedContainerName == signedNestedContainerName)

        try? FileManager.default.removeItem(at: nestedSignedContainerUrl)
        try? FileManager.default.removeItem(at: localExampleContainer)
        try? FileManager.default.removeItem(at: tempDirectory)
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

        guard let errorKey = viewModel.errorMessage?.key, let args = viewModel.errorMessage?.args else {
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
        mockFileUtil.getFileFromZipFileHandler = { _, _ in URL(fileURLWithPath: "mimetype") }
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
        mockFileUtil.getFileFromZipFileHandler = { _, _ in URL(fileURLWithPath: "mimetype") }
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

    @Test
    func removeSignature_success() async {
        let mockSignedContainer = SignedContainerProtocolMock()
        mockSignedContainer.getRawContainerFileHandler = { URL(fileURLWithPath: "/mock/path/mockContainer.asice") }
        mockSignedContainer.removeSignatureHandler = { _, _ in mockSignedContainer }

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)

        await viewModel.removeSignature(MockSignatureWrapper.mockSignatureWrapper())

        #expect(viewModel.errorMessage == nil)
    }

    @Test
    func removeSignature_throwErrorWhenContainerDataNotLoaded() async {
        await viewModel.removeSignature(MockSignatureWrapper.mockSignatureWrapper())

        let errorMessage = viewModel.errorMessage

        #expect(errorMessage == ToastMessage(key: "Failed to remove signature from container", args: []))
    }

    @Test
    func removeSignature_throwErrorWhenSignatureDoesNotExist() async {
        let mockSignedContainer = SignedContainerProtocolMock()
        mockSignedContainer.getRawContainerFileHandler = { URL(fileURLWithPath: "/mock/path/mockContainer.asice") }

        mockSignedContainer.removeSignatureHandler = { _, _ in
            throw DigiDocError.signatureRemovingFailed(
                ErrorDetail(message: "Error", userInfo: [:])
            )
        }

        await viewModel.removeSignature(MockSignatureWrapper.mockSignatureWrapper())

        let errorMessage = viewModel.errorMessage

        #expect(errorMessage == ToastMessage(key: "Failed to remove signature from container", args: []))
    }

    @Test
    func removeSignature_throwErrorWhenUnableToRemoveSignature() async {
        let mockSignature = MockSignatureWrapper.mockSignatureWrapper(pos: 0)
        let mockSignedContainer = SignedContainerProtocolMock()
        mockSignedContainer.getRawContainerFileHandler = { URL(fileURLWithPath: "/mock/path/mockContainer.asice") }
        mockSignedContainer.getSignaturesHandler = { [mockSignature] }

        mockSignedContainer.removeSignatureHandler = { _, _ in
            throw DigiDocError.signatureRemovingFailed(
                ErrorDetail(message: "Error", userInfo: [:])
            )
        }

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)

        await viewModel.removeSignature(mockSignature)

        let errorMessage = viewModel.errorMessage

        #expect(errorMessage == ToastMessage(key: "Failed to remove signature from container", args: []))
    }

    @Test
    func removeDataFile_success() async {
        let mockDataFile = MockDataFileWrapper.mockDataFileWrapper(fileId: "S1")
        let mockSignedContainer = SignedContainerProtocolMock()
        mockSignedContainer.getRawContainerFileHandler = { URL(fileURLWithPath: "/mock/path/mockContainer.asice") }
        mockSignedContainer.getDataFilesHandler = {
            [mockDataFile, MockDataFileWrapper.mockDataFileWrapper(fileId: "S2")]
        }

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)

        await viewModel.removeDataFile(mockDataFile)

        #expect(viewModel.errorMessage == nil)
        #expect(mockFileManager.removeItemCallCount == 0)
    }

    @Test
    func removeDataFile_successWithLastDataFile() async {
        let mockDataFile = MockDataFileWrapper.mockDataFileWrapper()
        let mockSignedContainer = SignedContainerProtocolMock()
        mockSignedContainer.getRawContainerFileHandler = { URL(fileURLWithPath: "/mock/path/mockContainer.asice") }
        mockSignedContainer.getDataFilesHandler = { [mockDataFile] }
        mockSignedContainer.removeDataFileHandler = { _, _ in mockSignedContainer }

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)

        await viewModel.removeDataFile(mockDataFile)

        #expect(viewModel.errorMessage == nil)
        #expect(mockFileManager.removeItemCallCount == 1)
        #expect(viewModel.isLastDataFileRemoved)
    }

    @Test
    func removeDataFile_throwErrorWhenContainerDataNotLoaded() async {
        let mockDataFile = MockDataFileWrapper.mockDataFileWrapper()
        await viewModel.removeDataFile(mockDataFile)

        let errorMessage = viewModel.errorMessage

        #expect(
            errorMessage == ToastMessage(
                key: "Failed to remove file from container",
                args: [mockDataFile.fileName]
            )
        )

        #expect(mockFileManager.removeItemCallCount == 0)
        #expect(!viewModel.isLastDataFileRemoved)
    }

    @Test
    func removeDataFile_throwErrorWhenDataFileDoesNotExist() async {
        let mockDataFile = MockDataFileWrapper.mockDataFileWrapper(fileId: "S1")
        let mockSignedContainer = SignedContainerProtocolMock()
        mockSignedContainer.getRawContainerFileHandler = { URL(fileURLWithPath: "/mock/path/mockContainer.asice") }
        mockSignedContainer.getDataFilesHandler = { [MockDataFileWrapper.mockDataFileWrapper(fileId: "S2")] }

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)

        await viewModel.removeDataFile(mockDataFile)

        let errorMessage = viewModel.errorMessage

        #expect(
            errorMessage == ToastMessage(
                key: "Failed to remove file from container",
                args: [mockDataFile.fileName]
            )
        )

        #expect(mockFileManager.removeItemCallCount == 0)
        #expect(!viewModel.isLastDataFileRemoved)
    }

    @Test
    func removeDataFile_throwErrorWhenUnableToRemoveDataFile() async {
        let mockDataFile = MockDataFileWrapper.mockDataFileWrapper(fileId: "S1")
        let mockSignedContainer = SignedContainerProtocolMock()
        mockSignedContainer.getRawContainerFileHandler = { URL(fileURLWithPath: "/mock/path/mockContainer.asice") }
        mockSignedContainer.getDataFilesHandler = {
            [mockDataFile, MockDataFileWrapper.mockDataFileWrapper(fileId: "S2")]
        }

        mockSignedContainer.removeDataFileHandler = { _, _ in
            throw DigiDocError.dataFileRemovingFailed(
                ErrorDetail(message: "Error", userInfo: [:])
            )
        }

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)

        await viewModel.removeDataFile(mockDataFile)

        let errorMessage = viewModel.errorMessage

        #expect(
            errorMessage == ToastMessage(
                key: "Failed to remove file from container",
                args: [mockDataFile.fileName]
            )
        )

        #expect(mockFileManager.removeItemCallCount == 0)
        #expect(!viewModel.isLastDataFileRemoved)
    }

    @Test
    func addDataFiles_successWithSingleFile() async {
        let mockDataFile = MockDataFileWrapper.mockDataFileWrapper(fileId: "S1")
        let mockAddedDataFile = MockDataFileWrapper.mockDataFileWrapper(
            fileId: "S2",
            fileName: "test.txt"
        )
        let mockSignedContainer = SignedContainerProtocolMock()
        mockSignedContainer.getRawContainerFileHandler = {
            URL(fileURLWithPath: "/mock/path/mockContainer.asice")
        }

        mockFileInspector.fileSizeHandler = { _ in 123 }

        let updatedMockSignedContainer = SignedContainerProtocolMock()
        updatedMockSignedContainer.getDataFilesHandler = { [mockDataFile, mockAddedDataFile] }
        mockSignedContainer.addDataFilesHandler = { _, _ in updatedMockSignedContainer }

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)

        guard let containerFile = await mockSignedContainer.getRawContainerFile() else {
            Issue.record("Unable to get container file")
            return
        }

        await viewModel.addDataFiles(
            [URL(fileURLWithPath: "/mock/path/test.txt")],
            to: containerFile
        )

        #expect(viewModel.successMessage == ToastMessage(key: "File successfully added", args: []))
        await #expect(updatedMockSignedContainer.getDataFiles().count == 2)
    }

    @Test
    func addDataFiles_successWithMultipleFiles() async {
        let mockDataFile = MockDataFileWrapper.mockDataFileWrapper(fileId: "S1")
        let mockAddedDataFile = MockDataFileWrapper.mockDataFileWrapper(
            fileId: "S2",
            fileName: "test.txt"
        )
        let mockAddedDataFile2 = MockDataFileWrapper.mockDataFileWrapper(
            fileId: "S3",
            fileName: "text.txt"
        )
        let mockSignedContainer = SignedContainerProtocolMock()
        mockSignedContainer.getRawContainerFileHandler = {
            URL(fileURLWithPath: "/mock/path/mockContainer.asice")
        }

        mockFileInspector.fileSizeHandler = { _ in 123 }

        let updatedMockSignedContainer = SignedContainerProtocolMock()
        updatedMockSignedContainer.getDataFilesHandler = { [mockDataFile, mockAddedDataFile, mockAddedDataFile2] }
        mockSignedContainer.addDataFilesHandler = { _, _ in updatedMockSignedContainer }

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)

        guard let containerFile = await mockSignedContainer.getRawContainerFile() else {
            Issue.record("Unable to get container file")
            return
        }

        await viewModel.addDataFiles(
            [URL(fileURLWithPath: "/mock/path/test.txt"),
             URL(fileURLWithPath: "/mock/path/text.txt")],
            to: containerFile
        )

        #expect(viewModel.successMessage == ToastMessage(key: "Files successfully added", args: []))
        await #expect(updatedMockSignedContainer.getDataFiles().count == 3)
    }

    @Test
    func addDataFiles_handleErrorWhenFileEmpty() async {
        let mockSignedContainer = SignedContainerProtocolMock()
        mockSignedContainer.getRawContainerFileHandler = {
            URL(fileURLWithPath: "/mock/path/mockContainer.asice")
        }

        mockFileInspector.fileSizeHandler = { _ in 0 }

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)

        guard let containerFile = await mockSignedContainer.getRawContainerFile() else {
            Issue.record("Unable to get container file")
            return
        }

        await viewModel.addDataFiles(
            [URL(fileURLWithPath: "/mock/path/test.txt")],
            to: containerFile
        )

        #expect(viewModel.errorMessage == ToastMessage(key: "Invalid file size", args: []))
        #expect(mockSignedContainer.addDataFilesCallCount == 0)
    }

    @Test
    func addDataFiles_handleErrorWhenNoDataFiles() async {
        let mockSignedContainer = SignedContainerProtocolMock()
        mockSignedContainer.getRawContainerFileHandler = {
            URL(fileURLWithPath: "/mock/path/mockContainer.asice")
        }

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)

        guard let containerFile = await mockSignedContainer.getRawContainerFile() else {
            Issue.record("Unable to get container file")
            return
        }

        await viewModel.addDataFiles([], to: containerFile)

        #expect(viewModel.errorMessage == ToastMessage(key: "Could not load selected files", args: []))
        #expect(mockSignedContainer.addDataFilesCallCount == 0)
    }

    @Test
    func addDataFiles_handleErrorWhenFileAlreadyExists() async {
        let mockFileName = "test.txt"
        let mockDataFile = MockDataFileWrapper.mockDataFileWrapper(fileId: "S1")
        let mockDataFile2 = MockDataFileWrapper.mockDataFileWrapper(
            fileId: "S2",
            fileName: mockFileName
        )
        let mockSignedContainer = SignedContainerProtocolMock()
        mockSignedContainer.getRawContainerFileHandler = {
            URL(fileURLWithPath: "/mock/path/mockContainer.asice")
        }

        mockSignedContainer.getDataFilesHandler = {
            [mockDataFile, mockDataFile2]
        }

        mockFileInspector.fileSizeHandler = { _ in 123 }

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)

        guard let containerFile = await mockSignedContainer.getRawContainerFile() else {
            Issue.record("Unable to get container file")
            return
        }

        await viewModel.addDataFiles(
            [URL(fileURLWithPath: "/mock/path/\(mockFileName)")],
            to: containerFile
        )

        #expect(viewModel.errorMessage == ToastMessage(key: "Document already exists", args: [mockFileName]))
        await #expect(mockSignedContainer.getDataFiles().count == 2)
    }

    @Test
    func addDataFiles_handleErrorWhenPartialAddingSucceeds() async throws {
        let testFile = try TestFileUtil.createSampleFile(name: "text", withExtension: "txt")
        let testFile2 = try TestFileUtil.createSampleFile(name: "text2", withExtension: "txt")
        let testFile3 = try TestFileUtil.createSampleFile(name: "test", withExtension: "txt")
        let containerFile = TestFileUtil.pathForResourceFile(fileName: "example_no_signatures", ext: "asice")

        guard let exampleContainer = containerFile else {
            Issue.record("Unable to get resource file")
            return
        }

        let tempDirectory = try TestFileUtil.getTemporaryDirectory(
            subfolder: "SigningViewModelTests-handleErrorWhenPartialAddingSucceeds"
        )

        let localExampleContainer = tempDirectory.appending(
            path: "\(UUID().uuidString)-\(exampleContainer.lastPathComponent)",
            directoryHint: .notDirectory
        )

        try FileManager.default.copyItem(
            at: exampleContainer,
            to: localExampleContainer
        )

        defer {
            try? FileManager.default.removeItem(at: localExampleContainer)
            try? FileManager.default.removeItem(at: tempDirectory)
        }

        let signedContainer = try await SignedContainer.openOrCreate(
            dataFiles: [localExampleContainer],
            isSivaConfirmed: true
        )

        mockMimeTypeDecoder.parseHandler = { _ in
            return ContainerType.none
        }

        await viewModel.loadContainerData(signedContainer: signedContainer)

        let rawContainerFile = await signedContainer.getRawContainerFile()

        guard let containerFile = rawContainerFile else {
            Issue.record("Unable to get raw container file")
            return
        }

        await viewModel.addDataFiles([
            testFile, testFile2, testFile3
        ], to: containerFile)

        #expect(viewModel.errorMessage == ToastMessage(key: "Multiple documents already exist", args: ["2"]))
        #expect(viewModel.dataFiles.count == 3)
    }

    @Test
    func addDataFiles_handleErrorWhenNoFilesAreAdded() async throws {
        let testFile = try TestFileUtil.createSampleFile(name: "text", withExtension: "txt")
        let testFile2 = try TestFileUtil.createSampleFile(name: "text2", withExtension: "txt")
        let containerFile = TestFileUtil.pathForResourceFile(fileName: "example_no_signatures", ext: "asice")

        guard let exampleContainer = containerFile else {
            Issue.record("Unable to get resource file")
            return
        }

        let tempDirectory = try TestFileUtil.getTemporaryDirectory(
            subfolder: "SigningViewModelTests-handleErrorWhenNoFilesAreAdded"
        )

        let localExampleContainer = tempDirectory.appending(
            path: "\(UUID().uuidString)-\(exampleContainer.lastPathComponent)"
        )

        try FileManager.default.copyItem(
            at: exampleContainer,
            to: localExampleContainer
        )

        defer {
            try? FileManager.default.removeItem(at: localExampleContainer)
            try? FileManager.default.removeItem(at: tempDirectory)
        }

        let signedContainer = try await SignedContainer.openOrCreate(
            dataFiles: [localExampleContainer],
            isSivaConfirmed: true
        )

        mockMimeTypeDecoder.parseHandler = { _ in
            return ContainerType.none
        }

        await viewModel.loadContainerData(signedContainer: signedContainer)

        let rawContainerFile = await signedContainer.getRawContainerFile()

        guard let containerFile = rawContainerFile else {
            Issue.record("Unable to get raw container file")
            return
        }

        await viewModel.addDataFiles([
            testFile, testFile2
        ], to: containerFile)

        #expect(viewModel.errorMessage == ToastMessage(key: "Multiple documents already exist", args: ["2"]))
        #expect(viewModel.dataFiles.count == 2)
    }

    @Test
    func convertToCryptoContainer_successWithExistingContainer() async throws {
        let mockSignedContainer = SignedContainerProtocolMock()

        mockSignedContainer.getRawContainerFileHandler = {
            URL(filePath: "/mock/path/to/container.asice")
        }

        let dataFileWrapper = MockDataFileWrapper.mockDataFileWrapper(
            fileId: "1",
            fileName: "container.asice",
            fileSize: 123,
            mediaType: CommonsLib.Constants.MimeType.Asice
        )

        let signatureWrapper = MockSignatureWrapper.mockSignatureWrapper()

        mockSignedContainer.getDataFilesHandler = { [dataFileWrapper] }
        mockSignedContainer.getSignaturesHandler = { [signatureWrapper] }

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)

        let isConverted = await viewModel.convertToCryptoContainer()

        #expect(isConverted)
        #expect(mockSharedContainerViewModel.setSignedContainerCallCount == 1)
        #expect(mockSharedContainerViewModel.clearContainersCallCount == 1)
        #expect(mockSharedContainerViewModel.setAddedFilesCountCallCount == 1)
        #expect(mockSharedContainerViewModel.setCryptoContainerCallCount == 1)
        #expect(mockContainerUtil.getContainerDataFilesDirCallCount == 0)
    }

    @Test
    func convertToCryptoContainer_successWithUnsignedContainer() async throws {
        let mockSignedContainer = SignedContainerProtocolMock()

        mockSignedContainer.getRawContainerFileHandler = {
            URL(filePath: "/mock/path/to/container.asice")
        }

        mockContainerUtil.getContainerDataFilesDirHandler = { _ in
            URL(filePath: "/mock/path/to/container.asice/datafiles")
        }

        mockSignedContainer.saveDataFileHandler = { _, _ in
            URL(filePath: "/mock/path/to/container.asice/datafiles/text.txt")
        }

        let dataFileWrapper = MockDataFileWrapper.mockDataFileWrapper(
            fileId: "1",
            fileName: "text.txt",
            fileSize: 123,
            mediaType: CommonsLib.Constants.MimeType.Default
        )

        mockSignedContainer.getDataFilesHandler = { [dataFileWrapper] }
        mockSignedContainer.getSignaturesHandler = { [] }

        await viewModel.loadContainerData(signedContainer: mockSignedContainer)

        let isConverted = await viewModel.convertToCryptoContainer()

        #expect(isConverted)
        #expect(mockSharedContainerViewModel.setSignedContainerCallCount == 1)
        #expect(mockSharedContainerViewModel.clearContainersCallCount == 1)
        #expect(mockSharedContainerViewModel.setAddedFilesCountCallCount == 1)
        #expect(mockSharedContainerViewModel.setCryptoContainerCallCount == 1)
        #expect(mockContainerUtil.getContainerDataFilesDirCallCount == 1)
    }

    @Test
    func convertToCryptoContainer_returnFalseWhenContainerDoesntExist() async throws {

        await viewModel.loadContainerData(signedContainer: nil)

        let isConverted = await viewModel.convertToCryptoContainer()

        #expect(!isConverted)
        #expect(mockSharedContainerViewModel.setSignedContainerCallCount == 0)
        #expect(mockSharedContainerViewModel.clearContainersCallCount == 0)
        #expect(mockSharedContainerViewModel.setAddedFilesCountCallCount == 0)
        #expect(mockSharedContainerViewModel.setCryptoContainerCallCount == 0)
        #expect(mockContainerUtil.getContainerDataFilesDirCallCount == 0)
    }
}
