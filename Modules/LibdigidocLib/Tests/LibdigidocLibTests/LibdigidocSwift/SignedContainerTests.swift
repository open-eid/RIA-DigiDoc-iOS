/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
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

        configurationProvider = try TestConfigurationProviderUtil.getConfigurationProvider()

        do {
            try await DigiDocConf.initDigiDoc(configuration: configurationProvider, userAgent: "TestUserAgent")
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
    func openOrCreateContainer_throwContainerCreationFailedErrorWhenFileDoesNotExist() async throws {
        let notExistingFile = "notExistingFile.txt"
        let notExistingContainerUrl = URL(
            filePath: notExistingFile,
            directoryHint: .inferFromPath,
            relativeTo: nil
        )

        do {
            _ = try await SignedContainer.openOrCreate(dataFiles: [notExistingContainerUrl], isSivaConfirmed: true)
            Issue.record("Expected 'addingFilesToContainerFailed' error")
            return
        } catch let error as DigiDocError {
            switch error {
            case .containerCreationFailed(let errorDetail):
                #expect(
                    notExistingContainerUrl
                        .deletingPathExtension()
                        .appendingPathExtension(Constants.Extension.Asice).lastPathComponent == errorDetail
                        .userInfo["fileName"] as? String
                )
            default:
                Issue.record("Unexpected error: \(error.localizedDescription)")
                return
            }
        }
    }

    @Test
    func renameContainer_success() async throws {
        let exampleContainer = try #require( TestFileUtil.pathForResourceFile(fileName: "example", ext: "asice"))
        let newFileName = "renamed.asice"
        let tempDirectoryURL = TestFileUtil.getTemporaryDirectory(
            subfolder: "SignedContainerTests"
        )
        let uniqueFileURL = tempDirectoryURL.appending(path: "renamed_unique.asice")

        let localExampleContainer = tempDirectoryURL.appending(path:
            "\(UUID().uuidString)-\(exampleContainer.lastPathComponent)"
        )

        try FileManager.default.copyItem(
            at: exampleContainer,
            to: localExampleContainer
        )

        defer {
            try? FileManager.default.removeItem(at: localExampleContainer)
            try? FileManager.default.removeItem(at: tempDirectoryURL)
        }

        mockContainerUtil.getContainerFileHandler = { _, _ in uniqueFileURL }

        mockContainerWrapper.saveDataFileHandler = { _, _, _ in uniqueFileURL }

        mockFileManager.moveItemHandler = { _, _ in
            do {
                try FileManager.default.moveItem(at: localExampleContainer, to: uniqueFileURL)
            } catch {
                Issue.record("Expected moveItem to succeed")
                return
            }
        }

        let container = SignedContainer(
            containerFile: localExampleContainer,
            isExistingContainer: true,
            container: mockContainerWrapper,
            fileManager: mockFileManager,
            containerUtil: mockContainerUtil
        )

        let renamedContainer = try await container.renameContainer(to: newFileName)

        #expect(mockFileManager.moveItemCallCount == 1)
        #expect(mockFileManager.moveItemArgValues.first?.srcURL == localExampleContainer)
        #expect(mockFileManager.moveItemArgValues.first?.dstURL == uniqueFileURL)

        let containerUrl = await renamedContainer.getRawContainerFile()

        #expect(containerUrl == uniqueFileURL)
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
        let exampleContainer = try #require( TestFileUtil.pathForResourceFile(fileName: "example", ext: "asice"))
        let emptyNewName = ""
        let tempDirectoryURL = TestFileUtil.getTemporaryDirectory(
            subfolder: "SignedContainerTests"
        )
        let defaultFileName = CommonsLib.Constants.Container.DefaultName
        let uniqueFileURL = tempDirectoryURL.appending(path: "\(defaultFileName)_unique.asice")

        let localExampleContainer = tempDirectoryURL.appending(path:
            "\(UUID().uuidString)-\(exampleContainer.lastPathComponent)"
        )

        try FileManager.default.copyItem(
            at: exampleContainer,
            to: localExampleContainer
        )

        defer {
            try? FileManager.default.removeItem(at: localExampleContainer)
            try? FileManager.default.removeItem(at: tempDirectoryURL)
        }

        mockContainerUtil.getContainerFileHandler = { url, _ in
            #expect(url.lastPathComponent.starts(with: defaultFileName))
            return uniqueFileURL
        }

        mockContainerWrapper.saveDataFileHandler = { _, _, _ in uniqueFileURL }

        mockFileManager.moveItemHandler = { _, _ in
            do {
                try FileManager.default.moveItem(at: localExampleContainer, to: uniqueFileURL)
            } catch {
                Issue.record("Expected moveItem to succeed")
                return
            }
        }

        let containerToRename = SignedContainer(
            containerFile: localExampleContainer,
            isExistingContainer: false,
            container: mockContainerWrapper,
            fileManager: mockFileManager,
            containerUtil: mockContainerUtil
        )

        let renamedContainer = try await containerToRename.renameContainer(to: emptyNewName)

        #expect(mockFileManager.moveItemCallCount == 1)
        #expect(mockFileManager.moveItemArgValues.first?.srcURL == localExampleContainer)
        #expect(mockFileManager.moveItemArgValues.first?.dstURL == uniqueFileURL)

        let containerUrl = await renamedContainer.getRawContainerFile()

        #expect(containerUrl == uniqueFileURL)
    }

    @Test
    func renameContainer_expectErrorWhenMoveItemThrowsError() async {
        let originalURL = URL(fileURLWithPath: "/tmp/original.asice")
        let newFileName = "renamed.asice"
        let directoryURL = originalURL.deletingLastPathComponent()
        let uniqueFileURL = directoryURL.appending(path: "renamed_unique.asice")

        mockContainerUtil.getContainerFileHandler = { _, _ in uniqueFileURL }

        mockFileManager.moveItemHandler = { _, _ in
            throw NSError(domain: "TestDomain - unable to rename container", code: 1, userInfo: nil)
        }

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
        let uniqueFileURL = directoryURL.appending(path: "renamed_unique.asice")
        let errorDomain = "TestDomain - unable to save container"

        mockContainerUtil.getContainerFileHandler = { _, _ in uniqueFileURL }

        mockFileManager.moveItemHandler = { _, _ in
            throw NSError(domain: errorDomain, code: 1, userInfo: nil)
        }

        let container = SignedContainer(
            containerFile: originalURL,
            isExistingContainer: true,
            container: mockContainerWrapper,
            fileManager: mockFileManager,
            containerUtil: mockContainerUtil
        )

        do {
            _ = try await container.renameContainer(to: newFileName)
            Issue.record("Expected to throw Error")
            return
        } catch {
            #expect((error as NSError).domain == errorDomain)
        }
    }

    @Test
    func getDataFile_success() async throws {
        mockContainerWrapper.getDataFilesHandler = {
            [MockDataFileWrapper.mockDataFileWrapper()]
        }

        mockContainerWrapper.saveDataFileHandler = { _, _, _ in
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

        mockContainerWrapper.saveDataFileHandler = { _, _, _ in
            testContainer
        }

        mockContainerWrapper.getSignaturesHandler = {
            [ MockSignatureWrapper.mockSignatureWrapper(format: "TimeStampToken") ]
        }

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
    func getSignaturesStatusCount_success() async throws {
        mockContainerWrapper.getSignaturesHandler = {[
            MockSignatureWrapper.mockSignatureWrapper(),
            MockSignatureWrapper.mockSignatureWrapper(signatureId: "S2"),
            MockSignatureWrapper.mockSignatureWrapper(signatureId: "S3", status: .unknown)
        ]}

        let signaturesStatusCount = await signedContainer.getSignaturesStatusCount()

        let validSignaturesCount = signaturesStatusCount[.valid]
        let unknownSignaturesCount = signaturesStatusCount[.unknown]
        let invalidSignaturesCount = signaturesStatusCount[.invalid]

        #expect(validSignaturesCount == 2)
        #expect(unknownSignaturesCount == 1)
        #expect(invalidSignaturesCount == 0)
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

        mockContainerWrapper.saveDataFileHandler = { _, _, _ in
            throw URLError(.fileDoesNotExist)
        }

        await #expect(throws: URLError.self) {
            _ = try await signedContainer.getNestedTimestampedContainer()
        }
    }

    @Test
    func isEmptyFileInContainer_returnTrue() async throws {
        mockContainerWrapper.getDataFilesHandler = {
            [MockDataFileWrapper.mockDataFileWrapper(
                fileName: "mockFile.txt",
                fileSize: 0,
                mediaType: Constants.MimeType.Default
            )]
        }

        let isEmptyFileInContainer = await signedContainer.isEmptyFileInContainer()

        #expect(isEmptyFileInContainer)
    }

    @Test
    func isEmptyFileInContainer_returnFalse() async throws {
        mockContainerWrapper.getDataFilesHandler = {
            [MockDataFileWrapper.mockDataFileWrapper(
                fileName: "mockFile.txt",
                fileSize: 123,
                mediaType: Constants.MimeType.Default
            )]
        }

        let isEmptyFileInContainer = await signedContainer.isEmptyFileInContainer()

        #expect(!isEmptyFileInContainer)
    }

    @Test
    func removeSignature_success() async throws {
        let mockNewContainerWrapper = ContainerWrapperProtocolMock()

        mockContainerWrapper.removeSignatureHandler = { _, _ in
            return mockNewContainerWrapper
        }

        mockNewContainerWrapper.getSignaturesHandler = {[
            MockSignatureWrapper.mockSignatureWrapper()
        ]}

        let container = try await signedContainer
            .removeSignature(index: 0, containerFile: URL(fileURLWithPath: "/mock/path/mockContainer.asice"))

        let signatures = await container.getSignatures()

        #expect(signatures.count == 1)
    }

    @Test
    func removeSignature_throwErrorWhenSignatureDoesNotExist() async throws {
        mockContainerWrapper.removeSignatureHandler = { _, _ in
            throw DigiDocError.signatureRemovingFailed(
                ErrorDetail(message: "Error", userInfo: [:])
            )
        }

        do {
            try await signedContainer
                .removeSignature(index: 0, containerFile: URL(fileURLWithPath: "/mock/path/mockContainer.asice"))
            Issue.record("Expected 'signatureRemovingFailed' error")
            return
        } catch let error as DigiDocError {
            switch error {
            case .signatureRemovingFailed:
                #expect(true)
            default:
                Issue.record("Unexpected error: \(error.localizedDescription)")
                return
            }
        }
    }

    @Test
    func removeDataFile_success() async throws {
        let mockNewContainerWrapper = ContainerWrapperProtocolMock()

        mockContainerWrapper.removeDataFileHandler = { _, _ in
            return mockNewContainerWrapper
        }

        mockNewContainerWrapper.getDataFilesHandler = {[
            MockDataFileWrapper.mockDataFileWrapper()
        ]}

        let container = try await signedContainer
            .removeDataFile(index: 0, containerFile: URL(fileURLWithPath: "/mock/path/mockContainer.asice"))

        let dataFiles = await container.getDataFiles()

        #expect(dataFiles.count == 1)
    }

    @Test
    func removeDataFile_throwErrorWhenSignatureDoesNotExist() async throws {
        mockContainerWrapper.removeDataFileHandler = { _, _ in
            throw DigiDocError.dataFileRemovingFailed(
                ErrorDetail(message: "Error", userInfo: [:])
            )
        }

        do {
            try await signedContainer
                .removeDataFile(index: 0, containerFile: URL(fileURLWithPath: "/mock/path/mockContainer.asice"))
            Issue.record("Expected 'dataFileRemovingFailed' error")
            return
        } catch let error as DigiDocError {
            switch error {
            case .dataFileRemovingFailed:
                #expect(true)
            default:
                Issue.record("Unexpected error: \(error.localizedDescription)")
                return
            }
        }
    }

    @Test
    func addDataFiles_success() async throws {
        let mockUpdatedContainerWrapper = ContainerWrapperProtocolMock()

        mockContainerWrapper.addDataFilesHandler = { _, _ in
            return mockUpdatedContainerWrapper
        }

        mockUpdatedContainerWrapper.getDataFilesHandler = {[
            MockDataFileWrapper.mockDataFileWrapper(),
            MockDataFileWrapper.mockDataFileWrapper()
        ]}

        let container = try await signedContainer
            .addDataFiles([
                URL(fileURLWithPath: "/mock/path/file.txt")
            ], to: URL(fileURLWithPath: "/mock/path/mockContainer.asice"))

        let dataFiles = await container.getDataFiles()

        #expect(dataFiles.count == 2)
    }

    @Test
    func addDataFiles_throwErrorWhenNoDataFiles() async throws {
        do {
            try await signedContainer.addDataFiles([], to: URL(fileURLWithPath: "/mock/path/mockContainer.asice"))
            Issue.record("Expected 'dataFileRemovingFailed' error")
            return
        } catch let error as DigiDocError {
            switch error {
            case .addingFilesToContainerFailed:
                #expect(true)
            default:
                Issue.record("Unexpected error: \(error.localizedDescription)")
                return
            }
        }
    }

    @Test
    func removeDataFile_throwErrorWhenAddingFilesDoesNotSucceed() async throws {
        mockContainerWrapper.addDataFilesHandler = { _, _ in
            throw DigiDocError.addingFilesToContainerFailed(
                ErrorDetail(message: "TestError", userInfo: [:])
            )
        }

        do {
            try await signedContainer
                .addDataFiles(
                    [URL(fileURLWithPath: "/mock/path/file.txt")],
                    to: URL(fileURLWithPath: "/mock/path/mockContainer.asice")
                )
            Issue.record("Expected 'addingFilesToContainerFailed' error")
            return
        } catch let error as DigiDocError {
            switch error {
            case .addingFilesToContainerFailed:
                #expect(true)
            default:
                Issue.record("Unexpected error: \(error.localizedDescription)")
                return
            }
        }
    }

    @Test
    func prepareSignature_success() async throws {
        let expectedData = Data([0x01, 0x02])
        let cert = Data([0xAA])
        let containerPath = URL(fileURLWithPath: "/mock/path/mockContainer.asice")
        let roleData = RoleData(
            roles: ["TestRole"],
            city: "TestCity",
            state: "TestState",
            country: "TestCountry",
            zipCode: "TestZipCode123"
        )
        let userAgent = "TestUserAgent"

        mockContainerWrapper.prepareSignatureHandler =
        { receivedCert, receivedPath, receivedRoleData, receivedAgent in

            #expect(receivedCert == cert)
            #expect(receivedPath == containerPath)
            #expect(receivedRoleData == roleData)
            #expect(receivedAgent == userAgent)

            return expectedData
        }

        let result = try await signedContainer.prepareSignature(
            cert: cert,
            containerPath: containerPath,
            roleData: roleData,
            userAgent: userAgent
        )

        #expect(result == expectedData)
    }

    @Test
    func prepareSignature_throwErrorWhenSignaturePreparingDoesNotSucceed() async {
        mockContainerWrapper.prepareSignatureHandler = { _, _, _, _ in
            throw NSError(domain: "TestError", code: 1)
        }

        do {
            _ = try await signedContainer
                .prepareSignature(
                    cert: Data(),
                    containerPath: URL(fileURLWithPath: "/mock/path/mockContainer.asice"),
                    roleData: RoleData(
                        roles: ["TestRole"],
                        city: "TestCity",
                        state: "TestState",
                        country: "TestCountry",
                        zipCode: "TestZipCode123"
                    ),
                    userAgent: "TestUserAgent"
                )
            Issue.record("Expected error to be thrown")
            return
        } catch {
            #expect(true)
        }
    }

    @Test
    func addSignature_success() async throws {
        let signature = Data([0x01, 0x02])
        let containerFile = URL(fileURLWithPath: "/mock/path/mockContainer.asice")
        let returnedMockContainerWrapper = ContainerWrapperProtocolMock()

        mockContainerWrapper.addSignatureHandler = { receivedSignature, receivedURL in
            #expect(receivedSignature == signature)
            #expect(receivedURL == containerFile)
            return returnedMockContainerWrapper
        }

        mockContainerWrapper.getSignaturesHandler = {
            return [MockSignatureWrapper.mockSignatureWrapper(
                signatureId: "1"
            )]
        }

        let result = try await signedContainer.addSignature(
            signature: signature,
            containerFile: containerFile
        )

        let resultSignatures = await result.getSignatures()
        let returnedMockContainerWrapperSignatures = await returnedMockContainerWrapper.getSignatures()

        await #expect(result.getRawContainerFile() == containerFile)
        #expect(resultSignatures == returnedMockContainerWrapperSignatures)
    }

    @Test
    func addSignature_propagatesErrorsFromContainer() async {
        mockContainerWrapper.addSignatureHandler = { _, _ in
            throw NSError(domain: "TestError", code: 1)
        }

        do {
            _ = try await signedContainer.addSignature(
                signature: Data(),
                containerFile: URL(fileURLWithPath: "/tmp/container.asice")
            )
            Issue.record("Expected error to be thrown")
            return
        } catch {
            #expect(true)
        }
    }
}
