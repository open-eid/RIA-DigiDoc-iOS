import Foundation
import Testing
import CommonsTestShared
import LibdigidocLibObjC
import CommonsLib
import ConfigLib
import UtilsLib
import UtilsLibMocks
import CommonsLibMocks
import LibdigidocLibSwiftMocks

@testable import LibdigidocLibSwift

private let isRealContainerOperationTestsEnabled = false

final class SignedContainerTests {

    private let configurationProvider: ConfigurationProvider
    private var signedContainer: SignedContainerProtocol!

    private let mockFileManager: FileManagerProtocolMock!
    private let mockContainerUtil: ContainerUtilProtocolMock!
    private let mockContainerWrapper: ContainerWrapperProtocolMock!

    init() async throws {
        mockFileManager = FileManagerProtocolMock()
        mockContainerUtil = ContainerUtilProtocolMock()
        mockContainerWrapper = ContainerWrapperProtocolMock()

        configurationProvider = TestConfigurationProviderUtil.getConfigurationProvider()

        do {
            try await DigiDocConf.initDigiDoc(configuration: configurationProvider)
        } catch let error as DigiDocError {
            switch error {
            case .alreadyInitialized:
                #expect(true)
            default:
                Issue.record("Unexpected error: \(error.localizedDescription)")
                return
            }
        }

        let tempFileURL = URL(fileURLWithPath: "/mock/path/mockFile.txt")

        signedContainer = SignedContainer(
            containerFile: tempFileURL,
            isExistingContainer: false,
            container: mockContainerWrapper,
            timestamps: [],
            fileManager: mockFileManager,
            containerUtil: mockContainerUtil
        )
    }

    @Test
    func getDataFiles_success() async throws {
        mockContainerWrapper.getDataFilesHandler = {
            [MockDataFileWrapper.mockDataFileWrapper()]
        }

        let dataFiles = await signedContainer.getDataFiles()

        #expect(dataFiles.count == 1)
    }

    @Test
    func getSignatures_success() async throws {
        let signatures = await signedContainer.getSignatures()
        #expect(signatures.isEmpty)
    }

    @Test
    func getContainerMimetype_success() async throws {
        mockContainerWrapper.getMimetypeHandler = {
            return CommonsLib.Constants.MimeType.Asice
        }

        let mimetype = await signedContainer.getContainerMimetype()
        #expect(!mimetype.isEmpty)
        #expect(CommonsLib.Constants.MimeType.Asice == mimetype)
    }

    @Test(.enabled(if: isRealContainerOperationTestsEnabled))
    func openOrCreate_success() async throws {
        let containerFile = TestFileUtil.pathForResourceFile(fileName: "example", ext: "asice")

        guard let exampleContainer = containerFile else {
            Issue.record("Unable to get resource file")
            return
        }

        let signedContainer = try await SignedContainer.openOrCreate(
            dataFiles: [exampleContainer], isSivaConfirmed: true
        )

        await #expect(signedContainer.getContainerMimetype() == CommonsLib.Constants.MimeType.Asice)
    }

    @Test
    func openOrCreateContainer_throwContainerCreationFailedErrorWithNoDatafiles() async throws {
        do {
            _ = try await SignedContainer.openOrCreate(dataFiles: [], isSivaConfirmed: true)
            Issue.record("Expected containerCreationFailed error")
            return
        } catch let error as DigiDocError {
            switch error {
            case .containerCreationFailed(let errorDetail):
                #expect(errorDetail.message == "Cannot create or open container. Datafiles are empty")
            default:
                Issue.record("Unexpected error: \(error.localizedDescription)")
                return
            }
        }
    }

    @Test
    func openOrCreateContainer_throwAddingFilesToContainerFailedErrorWhenFileDoesNotExist() async throws {
        let notExistingFile = "notExistingFile.txt"
        var notExistingContainerUrl: URL?
        if #available(iOS 16.0, *) {
            notExistingContainerUrl = URL(
                filePath: notExistingFile,
                directoryHint: .inferFromPath,
                relativeTo: nil
            )
        } else {
            notExistingContainerUrl = URL(fileURLWithPath: notExistingFile, isDirectory: false, relativeTo: nil)
        }

        guard let notExistingContainerLocation = notExistingContainerUrl else {
            Issue.record("Unable to get resource file")
            return
        }

        do {
            _ = try await SignedContainer.openOrCreate(dataFiles: [notExistingContainerLocation], isSivaConfirmed: true)
            Issue.record("Expected 'addingFilesToContainerFailed' error")
            return
        } catch let error as DigiDocError {
            switch error {
            case .addingFilesToContainerFailed(let errorDetail):
                #expect(notExistingContainerLocation.lastPathComponent == errorDetail.userInfo["fileName"])
            default:
                Issue.record("Unexpected error: \(error.localizedDescription)")
                return
            }
        }
    }

    @Test
    func renameContainer_success() async throws {
        let originalURL = URL(fileURLWithPath: "/tmp/original.asice")
        let newFileName = "renamed.asice"
        let directoryURL = originalURL.deletingLastPathComponent()
        let uniqueFileURL = directoryURL.appendingPathComponent("renamed_unique.asice")

        mockContainerUtil.getSignatureContainerFileHandler = { _, _ in uniqueFileURL }

        mockContainerWrapper.saveHandler = { _ in true }

        let container = SignedContainer(
            containerFile: originalURL,
            isExistingContainer: true,
            container: mockContainerWrapper,
            fileManager: mockFileManager,
            containerUtil: mockContainerUtil
        )

        let result = try await container.renameContainer(to: newFileName)

        #expect(mockFileManager.moveItemCallCount == 1)
        #expect(mockFileManager.moveItemArgValues.first?.srcURL == originalURL)
        #expect(mockFileManager.moveItemArgValues.first?.dstURL == uniqueFileURL)

        #expect(result == uniqueFileURL)
    }

    @Test
    func renameContainer_throwRenamingFailedErrorWithNilContainerFile() async {
        let container = SignedContainer(
            containerFile: nil,
            isExistingContainer: false,
            container: mockContainerWrapper,
            fileManager: mockFileManager,
            containerUtil: mockContainerUtil
        )

        do {
            _ = try await container.renameContainer(to: "newName.asice")
            Issue.record("Expected to throw DigiDocError.containerRenamingFailed")
            return
        } catch let error as DigiDocError {
            switch error {
            case .containerRenamingFailed:
                #expect(true)
            default:
                Issue.record("Expected containerRenamingFailed error")
                return
            }
        } catch {
            Issue.record("Unexpected error type")
            return
        }
    }

    @Test
    func renameContainer_returnURLWithDefaultNameWhenEmptyNewFileName() async throws {
        let originalURL = URL(fileURLWithPath: "/tmp/original.asice")
        let emptyNewName = ""
        let directoryURL = originalURL.deletingLastPathComponent()
        let defaultFileName = CommonsLib.Constants.Container.DefaultName
        let uniqueFileURL = directoryURL.appendingPathComponent("\(defaultFileName)_unique.asice")

        mockContainerUtil.getSignatureContainerFileHandler = { url, _ in
            #expect(url.lastPathComponent.starts(with: defaultFileName))
            return uniqueFileURL
        }

        mockContainerWrapper.saveHandler = { _ in true }

        let container = SignedContainer(
            containerFile: originalURL,
            isExistingContainer: false,
            container: mockContainerWrapper,
            fileManager: mockFileManager,
            containerUtil: mockContainerUtil
        )

        let resultURL = try await container.renameContainer(to: emptyNewName)

        #expect(mockFileManager.moveItemCallCount == 1)
        #expect(mockFileManager.moveItemArgValues.first?.srcURL == originalURL)
        #expect(mockFileManager.moveItemArgValues.first?.dstURL == uniqueFileURL)
        #expect(resultURL == uniqueFileURL)
    }

    @Test
    func renameContainer_expectErrorWhenMoveItemThrowsError() async {
        let originalURL = URL(fileURLWithPath: "/tmp/original.asice")
        let newFileName = "renamed.asice"
        let directoryURL = originalURL.deletingLastPathComponent()
        let uniqueFileURL = directoryURL.appendingPathComponent("renamed_unique.asice")

        mockContainerUtil.getSignatureContainerFileHandler = { _, _ in uniqueFileURL }

        mockFileManager.moveItemHandler = { _, _ in
            throw NSError(domain: "TestDomain", code: 1, userInfo: nil)
        }

        mockContainerWrapper.saveHandler = { _ in false }

        let container = SignedContainer(
            containerFile: originalURL,
            isExistingContainer: true,
            container: mockContainerWrapper,
            fileManager: mockFileManager,
            containerUtil: mockContainerUtil
        )

        do {
            _ = try await container.renameContainer(to: newFileName)
            Issue.record("Expected to throw error from moveItem")
            return
        } catch {
            #expect(true)
        }
    }

    @Test
    func renameContainer_throwSavingFailedWhenSaveReturnsFalse() async {
        let originalURL = URL(fileURLWithPath: "/tmp/original.asice")
        let newFileName = "renamed.asice"
        let directoryURL = originalURL.deletingLastPathComponent()
        let uniqueFileURL = directoryURL.appendingPathComponent("renamed_unique.asice")

        mockContainerUtil.getSignatureContainerFileHandler = { _, _ in uniqueFileURL }

        mockContainerWrapper.saveHandler = { _ in false }

        let container = SignedContainer(
            containerFile: originalURL,
            isExistingContainer: true,
            container: mockContainerWrapper,
            fileManager: mockFileManager,
            containerUtil: mockContainerUtil
        )

        do {
            _ = try await container.renameContainer(to: newFileName)
            Issue.record("Expected to throw DigiDocError.containerSavingFailed")
            return
        } catch let error as DigiDocError {
            switch error {
            case .containerSavingFailed:
                #expect(true)
            default:
                Issue.record("Expected containerSavingFailed error")
                return
            }
        } catch {
            Issue.record("Unexpected error type")
            return
        }
    }

    @Test
    func getDataFile_success() async throws {
        mockContainerWrapper.getDataFilesHandler = {
            [MockDataFileWrapper.mockDataFileWrapper()]
        }

        mockContainerWrapper.saveDataFileHandler = { _, _ in
            return URL(fileURLWithPath: "/tmp/mockFile.txt")
        }

        let dataFiles = await signedContainer.getDataFiles()

        guard let dataFile = dataFiles.first else {
            Issue.record("Unable to get datafile")
            return
        }

        let containerDataFile = try await signedContainer.saveDataFile(dataFile: dataFile)
        print(containerDataFile)
        #expect(containerDataFile.isValidURL())
        #expect(containerDataFile.lastPathComponent == dataFile.fileName)
    }

    @Test
    func getTimestamps_success() async {
        let timestamp = MockSignatureWrapper.mockSignatureWrapper()

        let signedContainerWithTimestamp = SignedContainer(
            containerFile: URL(fileURLWithPath: "/mock/path/container.asics"),
            isExistingContainer: false,
            container: mockContainerWrapper,
            timestamps: [timestamp],
            fileManager: mockFileManager,
            containerUtil: mockContainerUtil
        )

        let timestamps = await signedContainerWithTimestamp.getTimestamps()

        #expect(timestamps.count == 1)
        #expect(timestamps.first == timestamp)
    }

    @Test
    func isExistingContainer_returnTrue() async {
        let existingSignedContainer = SignedContainer(
            containerFile: URL(fileURLWithPath: "/mock/path/container.asics"),
            isExistingContainer: true,
            container: mockContainerWrapper,
            timestamps: [],
            fileManager: mockFileManager,
            containerUtil: mockContainerUtil
        )

        #expect(await existingSignedContainer.isExistingContainer())
    }

    @Test
    func isExistingContainer_returnFalse() async {
        let existingSignedContainer = SignedContainer(
            containerFile: URL(fileURLWithPath: "/mock/path/container.asics"),
            isExistingContainer: false,
            container: mockContainerWrapper,
            timestamps: [],
            fileManager: mockFileManager,
            containerUtil: mockContainerUtil
        )

        #expect(await !existingSignedContainer.isExistingContainer())
    }

    @Test
    func getNestedTimestampedContainer_success() async throws {
        let testContainer = try #require( TestFileUtil.pathForResourceFile(fileName: "example", ext: "asice"))
        let mockContainerDataFilesDirURL = URL(fileURLWithPath: "/mock/datafiles")
        mockContainerWrapper.getMimetypeHandler = { Constants.MimeType.Asics }
        mockContainerWrapper.getDataFilesHandler = {
            [MockDataFileWrapper.mockDataFileWrapper(
                fileName: testContainer.lastPathComponent,
                mediaType: Constants.MimeType.Asice
            )]
        }

        mockContainerUtil.getContainerDataFilesDirHandler = { _ in
            mockContainerDataFilesDirURL
        }

        mockContainerWrapper.saveDataFileHandler = { _, _ in
            testContainer
        }

        mockContainerWrapper.getSignaturesHandler = { [ MockSignatureWrapper.mockSignatureWrapper() ] }

        let nestedContainer = try await signedContainer.getNestedTimestampedContainer()

        #expect(await nestedContainer?.getTimestamps().count == 1)
        #expect(await nestedContainer?.isExistingContainer() == true)
        #expect(await nestedContainer?.getContainerMimetype() == Constants.MimeType.Asice)
    }

    @Test
    func getNestedTimestampedContainer_returnNilWhenContainerNotAsics() async throws {
        mockContainerWrapper.getMimetypeHandler = { Constants.MimeType.Asice }

        let nestedContainer = try await signedContainer.getNestedTimestampedContainer()

        #expect(nestedContainer == nil)
    }

    @Test
    func getNestedTimestampedContainer_returnNilWhenMoreThanOneDataFiles() async throws {
        mockContainerWrapper.getMimetypeHandler = { Constants.MimeType.Asics }

        mockContainerWrapper.getDataFilesHandler = {
            [
                MockDataFileWrapper.mockDataFileWrapper(
                    fileName: "mockContainer1.ddoc",
                    mediaType: Constants.MimeType.Ddoc
                ),
                MockDataFileWrapper.mockDataFileWrapper(
                    fileId: "2",
                    fileName: "mockContainer2.ddoc",
                    fileSize: 456,
                    mediaType: Constants.MimeType.Ddoc
                )
            ]
        }

        let nestedContainer = try await signedContainer.getNestedTimestampedContainer()

        #expect(nestedContainer == nil)
    }

    @Test
    func getNestedTimestampedContainer_throwErrorWhenGetContainerDataFilesDirThrowsError() async {
        mockContainerWrapper.getMimetypeHandler = { Constants.MimeType.Asics }

        mockContainerWrapper.getDataFilesHandler = {
            [MockDataFileWrapper.mockDataFileWrapper(
                fileName: "mockContainer1.ddoc",
                mediaType: Constants.MimeType.Ddoc
            )]
        }

        mockContainerUtil.getContainerDataFilesDirHandler = { _ in
            throw URLError(.fileDoesNotExist)
        }

        await #expect(throws: URLError.self) {
            _ = try await signedContainer.getNestedTimestampedContainer()
        }
    }

    @Test
    func getNestedTimestampedContainer_throwErrorWhenSaveDataFileThrowsError() async {
        let mockContainerDataFilesDirURL = URL(fileURLWithPath: "/mock/datafiles")
        mockContainerWrapper.getMimetypeHandler = { Constants.MimeType.Asics }

        mockContainerWrapper.getDataFilesHandler = {
            [MockDataFileWrapper.mockDataFileWrapper(
                fileName: "mockContainer1.ddoc",
                mediaType: Constants.MimeType.Ddoc
            )]
        }

        mockContainerUtil.getContainerDataFilesDirHandler = { _ in
            mockContainerDataFilesDirURL
        }

        mockContainerWrapper.saveDataFileHandler = { _, _ in
            throw URLError(.fileDoesNotExist)
        }

        await #expect(throws: URLError.self) {
            _ = try await signedContainer.getNestedTimestampedContainer()
        }
    }
}
