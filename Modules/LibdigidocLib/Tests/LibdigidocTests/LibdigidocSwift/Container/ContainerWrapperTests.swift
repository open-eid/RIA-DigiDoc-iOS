import Foundation
import Testing
import CommonsLib
import CommonsTestShared
import LibdigidocLibObjC
import ConfigLib
import UtilsLib
@testable import LibdigidocLibSwift

final class ContainerWrapperTests {

    private static let cacheDir = FileManager.default.temporaryDirectory.appendingPathComponent(
        UUID().uuidString
    )

    private var container: ContainerWrapperProtocol = ContainerWrapper()
    private let tempFileURL: URL
    private let configurationProvider: ConfigurationProvider

    init() async throws {
        await UtilsLibAssembler.shared.initialize()
        await ConfigLibAssembler.shared.initialize()
        await LibDigidocLibAssembler.shared.initialize()

        let configurationProperty = ConfigurationProperty(
            centralConfigurationServiceUrl: "https://id.eesti.ee",
            updateInterval: 4,
            versionSerial: 123,
            downloadDate: Date()
        )

        let centralConfigurationRepository = await CentralConfigurationRepository(
            centralConfigurationService: CentralConfigurationService(
                userAgent: "TestUserAgent",
                configurationProperty: configurationProperty
            )
        )

        let configurationProperties = ConfigurationProperties(suiteName: "ContainerWrapperTests")

        let configurationLoader = await ConfigurationLoader(
            centralConfigurationRepository: centralConfigurationRepository,
            configurationProperty: configurationProperty,
            configurationProperties: configurationProperties
        )

        let configurationRepository = await ConfigurationRepository(configurationLoader: configurationLoader)

        try DigiDocConf.observeConfigurationUpdates(configurationRepository: configurationRepository)

        try await configurationLoader.initConfiguration(cacheDir: ContainerWrapperTests.cacheDir)

        tempFileURL = TestFileUtil.createSampleFile()

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

        container = try await self.container.create(file: tempFileURL)
        try await container.addDataFiles(dataFiles: [tempFileURL])
        _ = try await container.save(file: tempFileURL)
    }

    deinit {
        container = ContainerWrapper()
        try? FileManager.default.removeItem(at: tempFileURL)
    }

    @Test
    func getSignatures_success() async throws {
        let signatures = await container.getSignatures()

        #expect(signatures.isEmpty)
    }

    @Test
    func getSignatures_returnEmptyResultWithoutContainerInitialization() async throws {
        let signatures = await ContainerWrapper().getSignatures()

        #expect(signatures.isEmpty)
    }

    @Test
    func getDataFiles_success() async throws {
        let dataFiles = await container.getDataFiles()

        #expect(1 == dataFiles.count)
    }

    @Test
    func getDataFiles_returnEmptyResultWithoutContainerInitialization() async throws {
        let signatures = await ContainerWrapper().getDataFiles()

        #expect(signatures.isEmpty)
    }

    @Test
    func getMimetype_success() async throws {
        let mimetype = await container.getMimetype()

        #expect(CommonsLib.Constants.MimeType.Asice == mimetype)
    }

    @Test
    func getMimetype_returnDefaultMimetypeWithoutContainerInitialization() async throws {
        let mimetype = await ContainerWrapper().getMimetype()

        #expect(CommonsLib.Constants.MimeType.Container == mimetype)
    }

    @Test
    func addDataFiles_success() async throws {
        let tempFileURL2 = TestFileUtil.createSampleFile()
        let tempFileURL3 = TestFileUtil.createSampleFile()

        try await container.addDataFiles(dataFiles: [tempFileURL2, tempFileURL3])

        let isSaved = try await container.save(file: tempFileURL)

        #expect(isSaved)

        defer {
            try? FileManager.default.removeItem(at: tempFileURL2)
            try? FileManager.default.removeItem(at: tempFileURL3)
        }

        let dataFiles = await container.getDataFiles()

        #expect(3 == dataFiles.count)
    }

    @Test
    func addDataFiles_throwErrorWithDuplicateFiles() async throws {
        let tempFileURL2 = TestFileUtil.createSampleFile()

        do {
            try await container.addDataFiles(dataFiles: [tempFileURL2, tempFileURL2])
        } catch let error as DigiDocError {
            switch error {
            case .addingFilesToContainerFailed(let errorDetail):
                #expect(
                    errorDetail.message == """
                    Document with same file name '\(tempFileURL2.lastPathComponent)' already exists.
                    """
                )
            default:
                Issue.record("Unexpected error: \(error.localizedDescription)")
                return
            }
        }

        let isSaved = try await container.save(file: tempFileURL)

        #expect(isSaved)

        defer {
            try? FileManager.default.removeItem(at: tempFileURL2)
        }

        let dataFiles = await container.getDataFiles()

        #expect(2 == dataFiles.count)
    }

    @Test
    func open_success() async throws {
        let containerFile = TestFileUtil.pathForResourceFile(fileName: "example", ext: "asice")

        guard let exampleContainer = containerFile else {
            Issue.record("Unable to get resource file")
            return
        }

        var containerWrapper: ContainerWrapperProtocol = ContainerWrapper()
        containerWrapper = try await containerWrapper.open(containerFile: exampleContainer)

        let existingContainer = await containerWrapper.getContainer()

        #expect(existingContainer != nil)
    }

    @Test
    func open_throwContainerOpeningFailedError() async throws {
        let tempSampleFileURL = TestFileUtil.createSampleFile()

        defer {
            try? FileManager.default.removeItem(at: tempSampleFileURL)
        }

        var containerWrapper: ContainerWrapperProtocol = ContainerWrapper()
        do {
            containerWrapper = try await containerWrapper.open(containerFile: tempSampleFileURL)

            Issue.record("Expected 'containerOpeningFailed' error")
            return
        } catch let error {
            switch error as? DigiDocError {
            case .containerOpeningFailed(let errorDetail):
                #expect(!errorDetail.message.isEmpty)
            default:
                Issue.record("Expected 'containerOpeningFailed' error")
                return
            }
        }
    }

    @Test
    func addDataFiles_throwAddingFilesToContainerFailedError() async throws {
        do {
            try await container.addDataFiles(dataFiles: [URL(string: "notAFileUrl")])

            Issue.record("Expected 'addingFilesToContainerFailed' error")
            return
        } catch let error {
            switch error as? DigiDocError {
            case .addingFilesToContainerFailed(let errorDetail):
                #expect(!errorDetail.message.isEmpty)
            default:
                Issue.record("Expected 'addingFilesToContainerFailed' error")
                return
            }
        }
    }

    @Test
    func saveDataFile_success() async throws {
        let tempSampleFileURL = TestFileUtil.createSampleFile()

        let testContainer = try await self.container.create(file: tempSampleFileURL)
        try await testContainer.addDataFiles(dataFiles: [tempFileURL])
        _ = try await testContainer.save(file: tempFileURL)

        let containerDataFiles = await container.getDataFiles()

        guard let dataFile = containerDataFiles.first else {
            Issue.record("Unable to get datafile")
            return
        }

        let savedFileURL = try await container.saveDataFile(dataFile: dataFile, FileManager.default.temporaryDirectory)

        #expect(savedFileURL != nil)
        #expect(savedFileURL.path.contains(dataFile.fileName))
    }

    @Test
    func saveDataFile_throwErrorWhenInvalidDataFile() async {
        let dataFile = DataFileWrapper(
            fileId: "",
            fileName: "datafile-\(UUID().uuidString)",
            fileSize: 0,
            mediaType: CommonsLib.Constants.Extension.Default)

        do {
            _ = try await container.saveDataFile(dataFile: dataFile, nil)
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
