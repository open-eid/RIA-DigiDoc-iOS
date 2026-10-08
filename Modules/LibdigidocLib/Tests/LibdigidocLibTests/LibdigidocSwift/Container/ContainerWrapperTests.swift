// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
        try? TestFileUtil.createSampleFile(),
        try? TestFileUtil.createSampleFile()
    ]
    private let mockSignature: SignatureWrapper

    init() async throws {
        mockSignature = MockSignatureWrapper.mockSignatureWrapper()

        mockFileManager = FileManagerProtocolMock()

        containerWrapper = ContainerWrapper(fileManager: mockFileManager)

        configurationProvider = try TestConfigurationProviderUtil.getConfigurationProvider()

        do {
            try await DigiDocConf.initDigiDoc(
                configuration: configurationProvider,
                userAgent: "TestUserAgent"
            )

            try await DigiDocConf.initDigiDoc(
                configuration: configurationProvider,
                userAgent: "TestUserAgent"
            )
        } catch let error as DigiDocError {
            switch error {
            case .alreadyInitialized:
                #expect(true)
            case .initializationFailed:
                break
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
        let sampleContainer = try await createSampleContainer(dataFileURLs: dataFileURLs)

        guard let containerFile = await sampleContainer.getRawContainerFile() else { return }

        let containerWrapper = await ContainerWrapper(
            containerURL: containerFile,
            dataFiles: sampleContainer.getDataFiles(),
            signatures: sampleContainer.getSignatures(),
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
        let sampleContainer = try await createSampleContainer(dataFileURLs: dataFileURLs)

        guard let containerFile = await sampleContainer.getRawContainerFile() else { return }

        let containerWrapper = await ContainerWrapper(
            containerURL: containerFile,
            mediatype: sampleContainer.getContainerMimetype(),
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
        let testFile = try TestFileUtil.createSampleFile()
        let sampleContainer = try await SignedContainer.openOrCreate(dataFiles: [testFile], isSivaConfirmed: true)

        guard let containerFile = await sampleContainer.getRawContainerFile() else { return }

        let containerWrapper = await ContainerWrapper(
            containerURL: containerFile,
            dataFiles: sampleContainer.getDataFiles(),
            fileManager: mockFileManager
        )

        defer {
            try? FileManager.default.removeItem(at: testFile)
            try? FileManager.default.removeItem(at: containerFile)
        }

        let dataFilesUrls: [URL] = dataFileURLs.compactMap { $0 }
        try await containerWrapper.addDataFiles(containerFile: containerFile, dataFiles: dataFilesUrls)

        let dataFiles = await containerWrapper.getDataFiles()

        #expect(dataFiles.count == 3)
    }

    @Test
    func addDataFiles_throwErrorWithDuplicateFiles() async throws {
        let sampleContainer = try await createSampleContainer(dataFileURLs: dataFileURLs)

        guard let containerFile = await sampleContainer.getRawContainerFile() else { return }

        let containerWrapper = await ContainerWrapper(
            containerURL: containerFile,
            dataFiles: sampleContainer.getDataFiles(),
            fileManager: mockFileManager
        )

        defer {
            try? FileManager.default.removeItem(at: containerFile)
        }

        let expectedErrorMessage = "Multiple documents already exist"

        do {
            let dataFilesUrls: [URL] = dataFileURLs.compactMap { $0 }
            try await containerWrapper.addDataFiles(containerFile: containerFile, dataFiles: dataFilesUrls)
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
    func openStaged_deliversTheSameResultsAsEagerOpenOnceValidationFinishes() async throws {
        let containerFile = try copyExampleContainer()
        defer { try? FileManager.default.removeItem(at: containerFile.deletingLastPathComponent()) }

        let expected = try await ContainerWrapper(fileManager: mockFileManager)
            .open(containerFile: containerFile, isSivaConfirmed: true)
            .getSignatures()
        try #require(!expected.isEmpty)
        try #require(
            expected.contains { !$0.diagnosticsInfo.isEmpty || $0.status != .unknown },
            "The fixture's results must differ from the unvalidated placeholders, or this test proves nothing"
        )

        let staged = try await ContainerWrapper(fileManager: mockFileManager)
            .openStaged(containerFile: containerFile, isSivaConfirmed: true)
        #expect(await staged.getSignatures().count == expected.count)

        await staged.awaitValidation()
        let validated = await staged.getSignatures()

        #expect(validated.map(\.signatureId) == expected.map(\.signatureId))
        #expect(validated.map(\.status) == expected.map(\.status))
        #expect(validated.map(\.diagnosticsInfo) == expected.map(\.diagnosticsInfo))

        await staged.awaitValidation()
        #expect(await staged.getSignatures().map(\.diagnosticsInfo) == expected.map(\.diagnosticsInfo))
    }

    @Test
    func cancelValidation_letsAwaitValidationReturn() async throws {
        let containerFile = try copyExampleContainer()
        defer { try? FileManager.default.removeItem(at: containerFile.deletingLastPathComponent()) }

        let staged = try await ContainerWrapper(fileManager: mockFileManager)
            .openStaged(containerFile: containerFile, isSivaConfirmed: true)

        await staged.cancelValidation()
        await staged.awaitValidation()

        #expect(await !staged.getSignatures().isEmpty)
    }

    @Test
    func awaitValidation_returnsImmediatelyWhenNothingIsValidating() async {
        await containerWrapper.awaitValidation()

        #expect(await containerWrapper.getSignatures().isEmpty)
    }

    private func copyExampleContainer() throws -> URL {
        let example = try #require(TestFileUtil.pathForResourceFile(fileName: "example", ext: "asice"))
        let directory = try TestFileUtil.getTemporaryDirectory(
            subfolder: "ContainerWrapperTests/\(UUID().uuidString)"
        )
        let copy = directory.appending(path: "example.asice")
        try FileManager.default.copyItem(at: example, to: copy)
        return copy
    }

    @Test
    func open_success() async throws {
        let dataFilesUrls: [URL] = dataFileURLs.compactMap { $0 }
        let signedContainer = try await SignedContainer.openOrCreate(
            dataFiles: [dataFilesUrls.first ?? URL(fileURLWithPath: "")], isSivaConfirmed: true
        )

        let container = try await containerWrapper.open(containerFile: signedContainer.getRawContainerFile() ??
                  URL(fileURLWithPath: ""), isSivaConfirmed: true)

        let dataFiles = await container.getDataFiles()

        #expect(dataFiles.count == 1)
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
        let sampleContainer = try await createSampleContainer(dataFileURLs: dataFileURLs)

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
        let sampleContainer = try await createSampleContainer(dataFileURLs: dataFileURLs)

        guard let containerFile = await sampleContainer.getRawContainerFile() else { return }

        let containerWrapper = await ContainerWrapper(
            containerURL: containerFile,
            dataFiles: sampleContainer.getDataFiles(),
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

        let savedFileURL = try await containerWrapper.saveDataFile(dataFile: dataFile)

        #expect(savedFileURL.isValidURL())
        #expect(savedFileURL.lastPathComponent == dataFile.fileName)
    }

    @Test
    func saveDataFile_throwErrorWhenInvalidDataFile() async throws {
        let dataFile = MockDataFileWrapper.mockDataFileWrapper(
            fileId: "",
            fileName: "datafile-\(UUID().uuidString)",
            fileSize: 0,
            mediaType: CommonsLib.Constants.Extension.Default)

        do {
            _ = try await containerWrapper.saveDataFile(dataFile: dataFile)
            Issue.record("Expected an error")
            return
        } catch let error as DigiDocError {
            guard case .containerDataFileSavingFailed = error else {
                Issue.record("Unexpected DigiDocError error: \(error)")
                return
            }
            #expect(true)
        } catch {
            Issue.record("Unexpected error: \(error)")
            return
        }
    }

    @Test
    func removeSignature_success() async throws {
        let containerFile = TestFileUtil.pathForResourceFile(fileName: "example", ext: "asice")

        guard let exampleContainer = containerFile else {
            Issue.record("Unable to get resource file")
            return
        }

        let tempDirectory = try TestFileUtil.getTemporaryDirectory(
            subfolder: "ContainerWrapperTests"
        )

        let localExampleContainer = tempDirectory.appending(path:
            "\(UUID().uuidString)-\(exampleContainer.lastPathComponent)"
        )

        try FileManager.default.copyItem(
            at: exampleContainer,
            to: localExampleContainer
        )

        defer {
            try? FileManager.default.removeItem(at: localExampleContainer)
            try? FileManager.default.removeItem(at: tempDirectory)
        }

        let updatedContainerWrapper = try await containerWrapper.removeSignature(
            index: 0,
            containerFile: localExampleContainer
        )

        let signatures = await updatedContainerWrapper.getSignatures()

        #expect(signatures.count == 1)
    }

    @Test
    func removeSignature_throwErrorWhenSignatureDoesNotExist() async throws {
        let sampleContainer = try await createSampleContainer(dataFileURLs: dataFileURLs)

        guard let containerFile = await sampleContainer.getRawContainerFile() else { return }

        defer {
            try? FileManager.default.removeItem(at: containerFile)
        }

        do {
            try await containerWrapper.removeSignature(index: 0, containerFile: containerFile)
            Issue.record("Expected an error")
            return
        } catch let error as DigiDocError {
            #expect(error.localizedDescription.contains("Incorrect signature id"))
        } catch {
            Issue.record("Unexpected error: \(error)")
            return
        }
    }

    @Test
    func removeDataFile_success() async throws {
        let containerFile = TestFileUtil.pathForResourceFile(fileName: "example_no_signatures", ext: "asice")

        guard let exampleContainer = containerFile else {
            Issue.record("Unable to get resource file")
            return
        }

        let tempDirectory = try TestFileUtil.getTemporaryDirectory(
            subfolder: "ContainerWrapperTests"
        )

        let localExampleContainer = tempDirectory.appending(path:
            "\(UUID().uuidString)-\(exampleContainer.lastPathComponent)"
        )

        try FileManager.default.copyItem(
            at: exampleContainer,
            to: localExampleContainer
        )

        defer {
            try? FileManager.default.removeItem(at: localExampleContainer)
            try? FileManager.default.removeItem(at: tempDirectory)
        }

        let updatedContainerWrapper = try await containerWrapper.removeDataFile(
            index: 0,
            containerFile: localExampleContainer
        )

        let dataFiles = await updatedContainerWrapper.getDataFiles()

        #expect(dataFiles.count == 1)
    }

    @Test
    func removeDataFile_throwErrorWhenDataFileDoesNotExist() async throws {
        let sampleContainer = try await createSampleContainer(dataFileURLs: dataFileURLs)

        guard let containerFile = await sampleContainer.getRawContainerFile() else { return }

        defer {
            try? FileManager.default.removeItem(at: containerFile)
        }

        do {
            try await containerWrapper.removeDataFile(index: 99, containerFile: containerFile)
            Issue.record("Expected an error")
            return

        } catch let error as DigiDocError {
            #expect(error.localizedDescription.contains("Incorrect document id"))
        } catch {
            Issue.record("Unexpected error: \(error)")
            return
        }
    }

    @Test
    func libdigidocppVersion_isNonEmpty() {
        #expect(!ContainerWrapper.libdigidocppVersion().isEmpty)
    }

    @discardableResult
    private func createSampleContainer(dataFileURLs: [URL?]) async throws -> SignedContainerProtocol {
        let dataFilesUrls: [URL] = dataFileURLs.compactMap { $0 }
        return try await SignedContainer.openOrCreate(dataFiles: dataFilesUrls, isSivaConfirmed: true)
    }
}
