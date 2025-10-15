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
        mockSignature = MockSignatureWrapper.mockSignatureWrapper()

        mockFileManager = FileManagerProtocolMock()

        containerWrapper = ContainerWrapper(fileManager: mockFileManager)

        configurationProvider = try TestConfigurationProviderUtil.getConfigurationProvider()

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
        let sampleContainer = try await SignedContainer.openOrCreate(dataFiles: dataFileURLs, isSivaConfirmed: true)

        guard let containerFile = await sampleContainer.getRawContainerFile() else { return }

        let containerWrapper = ContainerWrapper(
            containerURL: containerFile,
            fileManager: mockFileManager
        )

        defer {
            try? FileManager.default.removeItem(at: containerFile)
        }

        let dataFiles = await containerWrapper.getDataFiles()

        #expect(dataFiles.count == 2)
    }

    @Test
    func getDataFiles_returnEmptyResultWithoutContainerInitialization() async throws {
        let dataFiles = await ContainerWrapper(fileManager: mockFileManager).getDataFiles()

        #expect(dataFiles.isEmpty)
    }

    @Test
    func getMimetype_success() async throws {
        let sampleContainer = try await SignedContainer.openOrCreate(dataFiles: dataFileURLs, isSivaConfirmed: true)

        guard let containerFile = await sampleContainer.getRawContainerFile() else { return }

        let containerWrapper = ContainerWrapper(
            containerURL: containerFile,
            fileManager: mockFileManager
        )

        defer {
            try? FileManager.default.removeItem(at: containerFile)
        }

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
        let testFile = TestFileUtil.createSampleFile()
        let sampleContainer = try await SignedContainer.openOrCreate(dataFiles: [testFile], isSivaConfirmed: true)

        guard let containerFile = await sampleContainer.getRawContainerFile() else { return }

        let containerWrapper = ContainerWrapper(
            containerURL: containerFile,
            fileManager: mockFileManager
        )

        defer {
            try? FileManager.default.removeItem(at: testFile)
            try? FileManager.default.removeItem(at: containerFile)
        }

        try await containerWrapper.addDataFiles(containerFile: containerFile, dataFiles: dataFileURLs)

        let dataFiles = await containerWrapper.getDataFiles()

        #expect(dataFiles.count == 3)
    }

    @Test
    func addDataFiles_throwErrorWithDuplicateFiles() async throws {
        let sampleContainer = try await SignedContainer.openOrCreate(dataFiles: dataFileURLs, isSivaConfirmed: true)

        guard let containerFile = await sampleContainer.getRawContainerFile() else { return }

        let containerWrapper = ContainerWrapper(
            containerURL: containerFile,
            fileManager: mockFileManager
        )

        defer {
            try? FileManager.default.removeItem(at: containerFile)
        }

        let fileName = dataFileURLs.first?.lastPathComponent ?? ""
        let expectedErrorMessage = "Document with same file name '\(fileName)' already exists."

        do {
            try await containerWrapper.addDataFiles(containerFile: containerFile, dataFiles: dataFileURLs)
        } catch let error as DigiDocError {
            switch error {
            case .addingFilesToContainerFailed(let errorDetail):
                #expect(errorDetail.message == expectedErrorMessage)
            default:
                Issue.record("Unexpected error: \(error.localizedDescription)")
                return
            }
        }

        let dataFiles = await containerWrapper.getDataFiles()

        #expect(dataFiles.count == 2)
    }

    @Test
    func open_success() async throws {
        let signedContainer = try await SignedContainer.openOrCreate(
            dataFiles: [dataFileURLs.first ?? URL(fileURLWithPath: "")], isSivaConfirmed: true
        )

        _ = try await containerWrapper.open(containerFile: signedContainer.getRawContainerFile() ??
                  URL(fileURLWithPath: ""), isSivaConfirmed: true)

        let existingContainer = await containerWrapper.getContainer()

        #expect(existingContainer != nil)
    }

    @Test
    func open_throwContainerOpeningFailedError() async throws {
        do {
            let dummyURL = URL(fileURLWithPath: "/tmp/testfile.asice")
            _ = try await containerWrapper.open(containerFile: dummyURL, isSivaConfirmed: true)

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
        let sampleContainer = try await SignedContainer.openOrCreate(dataFiles: dataFileURLs, isSivaConfirmed: true)

        guard let containerFile = await sampleContainer.getRawContainerFile() else { return }

        let containerWrapper = ContainerWrapper(
            containerURL: containerFile,
            fileManager: mockFileManager
        )

        defer {
            try? FileManager.default.removeItem(at: containerFile)
        }

        let notAFileUrl = URL(string: "notAFileUrl")

        guard let mockNotAFileUrl = notAFileUrl else {
            Issue.record("Unable to create URL")
            return
        }

        do {
            try await containerWrapper.addDataFiles(containerFile: containerFile, dataFiles: [mockNotAFileUrl])
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
        let sampleContainer = try await SignedContainer.openOrCreate(dataFiles: dataFileURLs, isSivaConfirmed: true)

        guard let containerFile = await sampleContainer.getRawContainerFile() else { return }

        let containerWrapper = ContainerWrapper(
            containerURL: containerFile,
            fileManager: mockFileManager
        )

        defer {
            try? FileManager.default.removeItem(at: containerFile)
        }

        let containerDataFiles = await containerWrapper.getDataFiles()

        guard let dataFile = containerDataFiles.first else {
            Issue.record("Unable to get datafile")
            return
        }

        let savedFileURL = try await containerWrapper.saveDataFile(containerFile: containerFile, dataFile: dataFile)

        #expect(savedFileURL.isValidURL())
        #expect(savedFileURL.lastPathComponent == dataFile.fileName)
    }

    @Test
    func saveDataFile_throwErrorWhenInvalidDataFile() async throws {
        let sampleContainer = try await SignedContainer.openOrCreate(dataFiles: dataFileURLs, isSivaConfirmed: true)

        guard let containerFile = await sampleContainer.getRawContainerFile() else { return }

        defer {
            try? FileManager.default.removeItem(at: containerFile)
        }

        let dataFile = MockDataFileWrapper.mockDataFileWrapper(
            fileId: "",
            fileName: "datafile-\(UUID().uuidString)",
            fileSize: 0,
            mediaType: CommonsLib.Constants.Extension.Default)

        do {
            _ = try await containerWrapper.saveDataFile(containerFile: containerFile, dataFile: dataFile)
            Issue.record("Expected an error")
            return
        } catch let error as DigiDocError {
            #expect(error.localizedDescription.contains("unable to save data file"))
        } catch {
            Issue.record("Unexpected error: \(error)")
            return
        }
    }
}
