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

    private let mockFileManager: FileManagerProtocolMock
    private let containerWrapper: ContainerWrapper
    private let configurationProvider: ConfigurationProvider

    private let mockContainerURL = URL(fileURLWithPath: "/tmp/path")
    private var mockFileURL = URL(fileURLWithPath: "/tmp/path/test.txt")

    private let dataFileURLs = [
        TestFileUtil.createSampleFile(),
        TestFileUtil.createSampleFile()
    ]
    private let mockSignature: SignatureWrapper

    init() async throws {
        mockSignature = SignatureWrapper(
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
            roles: ["Role 1", "Role 2"],
            city: "Test City",
            state: "Test State",
            country: "Test Country",
            zipCode: "Test12345",
            format: "BES/time-stamp",
            messageImprint: Data(),
            diagnosticsInfo: ""
        )

        let mockContainerURL = URL(fileURLWithPath: "/tmp/path")

        mockFileManager = FileManagerProtocolMock()

        containerWrapper = try await ContainerWrapper(fileManager: mockFileManager)
            .create(file: mockContainerURL)

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
        let signatures = await containerWrapper.getSignatures()

        #expect(signatures.isEmpty)
    }

    @Test
    func getSignatures_returnEmptyResultWithoutContainerInitialization() async throws {
        let signatures = await ContainerWrapper(fileManager: mockFileManager).getSignatures()

        #expect(signatures.isEmpty)
    }

    @Test
    func getDataFiles_success() async throws {
        try await containerWrapper.addDataFiles(dataFiles: dataFileURLs)

        let dataFiles = await containerWrapper.getDataFiles()

        #expect(dataFiles.count == 2)
    }

    @Test
    func getDataFiles_returnEmptyResultWithoutContainerInitialization() async throws {
        let signatures = await ContainerWrapper(fileManager: mockFileManager).getDataFiles()

        #expect(signatures.isEmpty)
    }

    @Test
    func getMimetype_success() async throws {
        let mimetype = await containerWrapper.getMimetype()

        #expect(CommonsLib.Constants.MimeType.Asice == mimetype)
    }

    @Test
    func getMimetype_returnDefaultMimetypeWithoutContainerInitialization() async throws {
        let mimetype = await ContainerWrapper(fileManager: mockFileManager).getMimetype()

        #expect(CommonsLib.Constants.MimeType.Container == mimetype)
    }

    @Test
    func addDataFiles_success() async throws {
        try await containerWrapper.addDataFiles(dataFiles: dataFileURLs)

        let isSaved = try await containerWrapper.save(file: dataFileURLs.first ?? URL(fileURLWithPath: ""))

        #expect(isSaved)

        let dataFiles = await containerWrapper.getDataFiles()

        #expect(dataFiles.count == 2)
    }

    @Test
    func addDataFiles_throwErrorWithDuplicateFiles() async throws {
        let tempFileURL = TestFileUtil.createSampleFile()
        let expectedErrorMessage = "Document with same file name '\(tempFileURL.lastPathComponent)' already exists."

        do {
            try await containerWrapper.addDataFiles(dataFiles: [tempFileURL, tempFileURL])
        } catch let error as DigiDocError {
            switch error {
            case .addingFilesToContainerFailed(let errorDetail):
                #expect(errorDetail.message == expectedErrorMessage)
            default:
                Issue.record("Unexpected error: \(error.localizedDescription)")
                return
            }
        }

        let isSaved = try await containerWrapper.save(file: tempFileURL)

        #expect(isSaved)

        let dataFiles = await containerWrapper.getDataFiles()

        #expect(dataFiles.count == 1)
    }

    func open_success() async throws {
        let signedContainer = try await SignedContainer.openOrCreate(
            dataFiles: [dataFileURLs.first ?? URL(fileURLWithPath: "")]
        )

        _ = try await containerWrapper
            .open(containerFile: signedContainer.getRawContainerFile() ?? URL(fileURLWithPath: ""))

        let existingContainer = await containerWrapper.getContainer()

        #expect(existingContainer != nil)
    }

    @Test
    func open_throwContainerOpeningFailedError() async throws {
        do {
            let dummyURL = URL(fileURLWithPath: "/tmp/testfile.asice")
            _ = try await containerWrapper.open(containerFile: dummyURL)

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
        do {
            try await containerWrapper.addDataFiles(dataFiles: [URL(string: "notAFileUrl")])
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

    @Test
    func saveDataFile_success() async throws {
        try await containerWrapper.addDataFiles(dataFiles: dataFileURLs)
        _ = try await containerWrapper.save(file: dataFileURLs.first ?? URL(fileURLWithPath: ""))

        let containerDataFiles = await containerWrapper.getDataFiles()

        guard let dataFile = containerDataFiles.first else {
            Issue.record("Unable to get datafile")
            return
        }

        let savedFileURL = try await containerWrapper.saveDataFile(dataFile: dataFile)

        #expect(savedFileURL.isValidURL())
        #expect(savedFileURL.lastPathComponent == dataFile.fileName)
    }

    @Test
    func saveDataFile_throwErrorWhenInvalidDataFile() async {
        let dataFile = DataFileWrapper(
            fileId: "",
            fileName: "datafile-\(UUID().uuidString)",
            fileSize: 0,
            mediaType: CommonsLib.Constants.Extension.Default)

        do {
            try await containerWrapper.addDataFiles(dataFiles: dataFileURLs)
            _ = try await containerWrapper.saveDataFile(dataFile: dataFile)
            Issue.record("Expected an error")
            return
        } catch let error as DigiDocError {
            #expect(error.localizedDescription.contains("Unable to save datafile"))
        } catch {
            Issue.record("Unexpected error: \(error)")
            return
        }
    }
}
