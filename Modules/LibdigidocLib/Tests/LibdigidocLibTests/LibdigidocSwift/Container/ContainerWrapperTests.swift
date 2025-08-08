import Foundation
import Testing
import CommonsLib
import CommonsTestShared
import LibdigidocLibObjC
import ConfigLib
import UtilsLib
import LibdigidocLibSwiftMocks
import UtilsLibMocks
import CommonsLibMocks

@testable import LibdigidocLibSwift

struct ContainerWrapperTests {

    private var mockFileManager: FileManagerProtocolMock
    private var mockContainer: ContainerWrapperProtocolMock
    private let configurationProvider: ConfigurationProvider

    init() async throws {
        mockFileManager = FileManagerProtocolMock()
        mockContainer = ContainerWrapperProtocolMock()
        configurationProvider = TestConfigurationProviderUtil.getConfigurationProvider()

        do {
            try await DigiDocConf.initDigiDoc(configuration: configurationProvider)
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
    }

    @Test
    func getSignatures_success() async throws {
        let signatures = await mockContainer.getSignatures()

        #expect(signatures.isEmpty)
    }

    @Test
    func getSignatures_returnEmptyResultWithoutContainerInitialization() async throws {
        let signatures = await ContainerWrapper(fileManager: mockFileManager).getSignatures()

        #expect(signatures.isEmpty)
    }

    @Test
    func getDataFiles_success() async throws {

        mockContainer.getDataFilesHandler = {
            return [
                DataFileWrapper(
                    fileId: "S1",
                    fileName: "mockFile",
                    fileSize: 123,
                    mediaType: CommonsLib.Constants.MimeType.Default
                )
            ]
        }

        let dataFiles = await mockContainer.getDataFiles()

        #expect(dataFiles.count == 1)
    }

    @Test
    func getDataFiles_returnEmptyResultWithoutContainerInitialization() async throws {
        let signatures = await ContainerWrapper(fileManager: mockFileManager).getDataFiles()

        #expect(signatures.isEmpty)
    }

    @Test
    func getMimetype_success() async throws {

        mockContainer.getMimetypeHandler = {
            return CommonsLib.Constants.MimeType.Asice
        }

        let mimetype = await mockContainer.getMimetype()

        #expect(CommonsLib.Constants.MimeType.Asice == mimetype)
    }

    @Test
    func getMimetype_returnDefaultMimetypeWithoutContainerInitialization() async throws {
        let mimetype = await ContainerWrapper(fileManager: mockFileManager).getMimetype()

        #expect(CommonsLib.Constants.MimeType.Container == mimetype)
    }

    @Test
    func addDataFiles_success() async throws {
        let mockFile = URL(fileURLWithPath: "mockFile")
        let mockFile2 = URL(fileURLWithPath: "mockFile2")

        mockContainer.saveHandler = { _ in
            return true
        }

        mockContainer.getDataFilesHandler = {
            return [
                DataFileWrapper(
                    fileId: "S1",
                    fileName: mockFile.lastPathComponent,
                    fileSize: 123,
                    mediaType: CommonsLib.Constants.MimeType.Default
                ),
                DataFileWrapper(
                    fileId: "S2",
                    fileName: mockFile2.lastPathComponent,
                    fileSize: 456,
                    mediaType: CommonsLib.Constants.MimeType.Default
                ),
                DataFileWrapper(
                    fileId: "S2",
                    fileName: "mockFile3",
                    fileSize: 456,
                    mediaType: CommonsLib.Constants.MimeType.Default
                )
            ]
        }

        try await mockContainer.addDataFiles(dataFiles: [mockFile, mockFile2])

        let isSaved = try await mockContainer.save(file: mockFile)

        #expect(isSaved)

        let dataFiles = await mockContainer.getDataFiles()

        #expect(dataFiles.count == 3)
    }

    @Test
    func addDataFiles_throwErrorWithDuplicateFiles() async throws {
        let mockFile = URL(fileURLWithPath: "mockFile")
        let expectedErrorMessage = "Document with same file name '\(mockFile.lastPathComponent)' already exists."
        let errorDetail = ErrorDetail(message: expectedErrorMessage, code: 123, userInfo: ["reason": "Test case"])

        mockContainer.addDataFilesHandler = { _ in
            throw DigiDocError.addingFilesToContainerFailed(errorDetail)
        }

        mockContainer.saveHandler = { _ in
            return true
        }

        mockContainer.getDataFilesHandler = {
            return [
                DataFileWrapper(
                    fileId: "S1",
                    fileName: mockFile.lastPathComponent,
                    fileSize: 123,
                    mediaType: CommonsLib.Constants.MimeType.Default
                ),
                DataFileWrapper(
                    fileId: "S2",
                    fileName: "mockFile2",
                    fileSize: 456,
                    mediaType: CommonsLib.Constants.MimeType.Default
                )
            ]
        }

        do {
            try await mockContainer.addDataFiles(dataFiles: [mockFile, mockFile])
        } catch let error as DigiDocError {
            switch error {
            case .addingFilesToContainerFailed(let errorDetail):
                #expect(errorDetail.message == expectedErrorMessage)
            default:
                Issue.record("Unexpected error: \(error.localizedDescription)")
                return
            }
        }

        let isSaved = try await mockContainer.save(file: mockFile)

        #expect(isSaved)

        let dataFiles = await mockContainer.getDataFiles()

        #expect(dataFiles.count == 2)
    }

    func open_success() async throws {

        mockContainer.getContainerHandler = {
            return ContainerWrapper(fileManager: mockFileManager)
        }

        let dummyURL = URL(fileURLWithPath: "/tmp/testfile.asice")
        _ = try await mockContainer.openHandler?(dummyURL)

        let existingContainer = await mockContainer.getContainer()

        #expect(existingContainer != nil)
    }

    @Test
    func open_throwContainerOpeningFailedError() async throws {
        let errorDetail = ErrorDetail(message: "An error occurred", code: 123, userInfo: ["reason": "Test case"])

        mockContainer.openHandler = { _ in
            throw DigiDocError.containerOpeningFailed(errorDetail)
        }

        do {
            let dummyURL = URL(fileURLWithPath: "/tmp/testfile.asice")
            _ = try await mockContainer.openHandler?(dummyURL)

            Issue.record("Expected 'containerOpeningFailed' error")
        } catch let error {
            switch error as? DigiDocError {
            case .containerOpeningFailed(let detail):
                #expect(!detail.message.isEmpty)
            default:
                Issue.record("Expected 'containerOpeningFailed' error")
            }
        }
    }

    @Test
    func addDataFiles_throwAddingFilesToContainerFailedError() async throws {
        let errorDetail = ErrorDetail(message: "An error occurred", code: 123, userInfo: ["reason": "Test case"])

        mockContainer.addDataFilesHandler = { _ in
            throw DigiDocError.addingFilesToContainerFailed(errorDetail)
        }

        do {
            try await mockContainer.addDataFiles(dataFiles: [URL(string: "notAFileUrl")])
            Issue.record("Expected 'addingFilesToContainerFailed' error")
        } catch let error {
            switch error as? DigiDocError {
            case .addingFilesToContainerFailed(let detail):
                #expect(!detail.message.isEmpty)
            default:
                Issue.record("Expected 'addingFilesToContainerFailed' error, got: \(error)")
            }
        }
    }
}
