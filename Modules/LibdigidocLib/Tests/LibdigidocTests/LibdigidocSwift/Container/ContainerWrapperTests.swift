import Foundation
import Testing
import Cuckoo
import CommonsLib
import CommonsTestShared
import LibdigidocLibObjC
import ConfigLib
import UtilsLib

@testable import LibdigidocLibSwift

final class ContainerWrapperTests {

    private var container: ContainerWrapperProtocol = ContainerWrapper()
    private let tempFileURL: URL
    private let configurationProvider: ConfigurationProvider

    init() async throws {
        await UtilsLibAssembler.shared.initialize()
        await ConfigLibAssembler.shared.initialize()
        await LibDigidocLibAssembler.shared.initialize()

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
}
