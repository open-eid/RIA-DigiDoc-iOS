import Foundation
import Testing
import Cuckoo
import CommonsTestShared
import LibdigidocLibObjC
import CommonsLib
import ConfigLib
import UtilsLib

@testable import LibdigidocLibSwift

final class SignedContainerTests {

    private let configurationProvider: ConfigurationProvider
    private var signedContainer: SignedContainerProtocol!

    init() async throws {
        await UtilsLibAssembler.shared.initialize()
        await ConfigLibAssembler.shared.initialize()
        await LibDigidocLibAssembler.shared.initialize()

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

        let tempFileURL = TestFileUtil.createSampleFile()

        defer {
            try? FileManager.default.removeItem(at: tempFileURL)
        }

        signedContainer = try await SignedContainer.openOrCreate(dataFiles: [tempFileURL])
    }

    @Test
    func getDataFiles_success() async throws {
        let dataFiles = await signedContainer.getDataFiles()

        #expect(1 == dataFiles.count)
    }

    @Test
    func getSignatures_success() async throws {
        let signatures = await signedContainer.getSignatures()
        #expect(signatures.isEmpty)
    }

    @Test
    func getContainerMimetype_success() async throws {
        let mimetype = await signedContainer.getContainerMimetype()
        #expect(!mimetype.isEmpty)
        #expect(CommonsLib.Constants.MimeType.Asice == mimetype)
    }

    @Test
    func openOrCreate_success() async throws {
        let containerFile = TestFileUtil.pathForResourceFile(fileName: "example", ext: "asice")

        guard let exampleContainer = containerFile else {
            Issue.record("Unable to get resource file")
            return
        }

        let signedContainer = try await SignedContainer.openOrCreate(
            dataFiles: [exampleContainer]
        )

        #expect(signedContainer != nil)
    }

    @Test
    func openOrCreateContainer_throwContainerCreationFailedErrorWithNoDatafiles() async throws {
        do {
            _ = try await SignedContainer.openOrCreate(dataFiles: [])
            Issue.record("Expected containerCreationFailed error")
            return
        } catch let error as DigiDocError {
            switch error {
            case .containerCreationFailed(let errorDetail):
                #expect("Cannot create or open container. Datafiles are empty" == errorDetail.message)
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
            _ = try await SignedContainer.openOrCreate(dataFiles: [notExistingContainerLocation])
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
}
