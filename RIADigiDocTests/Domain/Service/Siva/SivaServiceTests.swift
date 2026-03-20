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
import Testing
import LibdigidocLibSwift
import CommonsLib
import CommonsLibMocks
import LibdigidocLibSwiftMocks
import UtilsLibMocks

struct SivaServiceTests {
    private let mockMimetypeResolver: MimeTypeResolverProtocolMock
    private let mockFileManager: FileManagerProtocolMock
    private let mockContainerUtil: ContainerUtilProtocolMock
    private let mockFileUtil: FileUtilProtocolMock

    private let service: SivaServiceProtocol

    init() async throws {
        mockMimetypeResolver = MimeTypeResolverProtocolMock()
        mockFileManager = FileManagerProtocolMock()
        mockContainerUtil = ContainerUtilProtocolMock()
        mockFileUtil = FileUtilProtocolMock()

        service = SivaService(
            mimeTypeResolver: mockMimetypeResolver,
            fileManager: mockFileManager,
            containerUtil: mockContainerUtil,
            fileUtil: mockFileUtil
        )
    }

    @Test
    func isSivaConfirmationNeeded_returnFalseWithMultipleFiles() async {
        let files = [URL(fileURLWithPath: "/tmp/mockFile.txt"), URL(fileURLWithPath: "/tmp/mockFile2.pdf")]

        let isSivaConfirmationNeeded = await service.isSivaConfirmationNeeded(files: files)

        #expect(!isSivaConfirmationNeeded)
        #expect(mockMimetypeResolver.mimeTypeCallCount == 0)
    }

    @Test
    func isSivaConfirmationNeeded_returnFalseWithEmptyArray() async {
        let isSivaConfirmationNeeded = await service.isSivaConfirmationNeeded(files: [])

        #expect(!isSivaConfirmationNeeded)
        #expect(mockMimetypeResolver.mimeTypeCallCount == 0)
    }

    @Test
    func isSivaConfirmationNeeded_returnTrueWithValidSivaContainerMimetype() async {
        let file = URL(fileURLWithPath: "/tmp/mockSignedContainer.asics")

        mockMimetypeResolver.mimeTypeHandler = { url in
            #expect(url == file)
            return Constants.MimeType.Asics
        }

        let isSivaConfirmationNeeded = await service.isSivaConfirmationNeeded(files: [file])

        #expect(isSivaConfirmationNeeded)
        #expect(mockMimetypeResolver.mimeTypeCallCount == 1)
    }

    @Test
    func isSivaConfirmationNeeded_returnFalseWithNonSivaContainerMimetype() async {
        let file = URL(fileURLWithPath: "/tmp/other.txt")

        mockMimetypeResolver.mimeTypeHandler = { _ in Constants.MimeType.Default }

        let isSivaConfirmationNeeded = await service.isSivaConfirmationNeeded(files: [file])

        #expect(!isSivaConfirmationNeeded)
        #expect(mockMimetypeResolver.mimeTypeCallCount == 1)
    }

    @Test
    func isTimestampedContainer_returnTrue() async {
        let mockSignedContainer = SignedContainerProtocolMock()
        mockSignedContainer.getDataFilesHandler = {[
            MockDataFileWrapper.mockDataFileWrapper()
        ]}
        mockSignedContainer.getContainerMimetypeHandler = { Constants.MimeType.Asics }
        mockSignedContainer.getSignaturesHandler = {[
            MockSignatureWrapper.mockSignatureWrapper(format: "TimeStampToken")
        ]}

        let isTimestampedContainer = await service.isTimestampedContainer(signedContainer: mockSignedContainer)

        #expect(isTimestampedContainer)
        #expect(mockSignedContainer.getDataFilesCallCount == 1)
        #expect(mockSignedContainer.getContainerMimetypeCallCount == 1)
        #expect(mockSignedContainer.getSignaturesCallCount == 1)
    }

    @Test
    func isTimestampedContainer_returnFalseWithMultipleDataFiles() async {
        let mockSignedContainer = SignedContainerProtocolMock()
        mockSignedContainer.getDataFilesHandler = {[
            MockDataFileWrapper.mockDataFileWrapper(),
            MockDataFileWrapper.mockDataFileWrapper(fileId: "2", fileName: "mockFile2.txt", fileSize: 456)
        ]}
        mockSignedContainer.getContainerMimetypeHandler = { Constants.MimeType.Asics }
        mockSignedContainer.getSignaturesHandler = { [] }

        let isTimestampedContainer = await service.isTimestampedContainer(signedContainer: mockSignedContainer)

        #expect(!isTimestampedContainer)
    }

    @Test
    func isTimestampedContainer_returnFalseWithNonContainerMimetype() async {
        let mockSignedContainer = SignedContainerProtocolMock()
        mockSignedContainer.getDataFilesHandler = {[
            MockDataFileWrapper.mockDataFileWrapper()
        ]}
        mockSignedContainer.getContainerMimetypeHandler = { Constants.MimeType.Default }
        mockSignedContainer.getSignaturesHandler = {
            [MockSignatureWrapper.mockSignatureWrapper(format: "TimeStampToken")]
        }

        let isTimestampedContainer = await service.isTimestampedContainer(signedContainer: mockSignedContainer)

        #expect(!isTimestampedContainer)
    }

    @Test
    func isTimestampedContainer_returnFalseWithNonTimestampedSignatureFormat() async {
        let mockSignedContainer = SignedContainerProtocolMock()
        mockSignedContainer.getDataFilesHandler = {[
            MockDataFileWrapper.mockDataFileWrapper(fileName: "mockFile.ddoc")
        ]}
        mockSignedContainer.getContainerMimetypeHandler = { Constants.MimeType.Asics }
        mockSignedContainer.getSignaturesHandler = { [MockSignatureWrapper.mockSignatureWrapper(format: "CAdES")] }

        let isTimestampedContainer = await service.isTimestampedContainer(signedContainer: mockSignedContainer)

        #expect(!isTimestampedContainer)
    }

    @Test
    func isTimestampedContainer_returnFalseWithNoSignatures() async {
        let mockSignedContainer = SignedContainerProtocolMock()
        mockSignedContainer.getDataFilesHandler = {[
            MockDataFileWrapper.mockDataFileWrapper()
        ]}
        mockSignedContainer.getContainerMimetypeHandler = { Constants.MimeType.Asics }
        mockSignedContainer.getSignaturesHandler = { [] }

        let isTimestampedContainer = await service.isTimestampedContainer(signedContainer: mockSignedContainer)

        #expect(!isTimestampedContainer)
    }

    @Test
    func getTimestampedContainer_success() async throws {
        let mockMainSignedContainer = SignedContainerProtocolMock()
        let mockNestedSignedContainer = SignedContainerProtocolMock()
        mockMainSignedContainer.getNestedTimestampedContainerHandler = { mockNestedSignedContainer }

        let getTimestampedContainer = try await service.getTimestampedContainer(
            parentContainer: mockMainSignedContainer
        )

        #expect(getTimestampedContainer === mockNestedSignedContainer)
        #expect(mockMainSignedContainer.getNestedTimestampedContainerCallCount == 1)
    }

    @Test
    func getTimestampedContainer_throwsErrorWhenNestedContainerIsNil() async {
        let parentMock = SignedContainerProtocolMock()
        parentMock.getNestedTimestampedContainerHandler = { nil }

        do {
            _ = try await service.getTimestampedContainer(parentContainer: parentMock)
            Issue.record("Expected DigiDocError.containerOpeningFailed but no error was thrown")
            return
        } catch let error as DigiDocError {
            if case .containerOpeningFailed = error {
                #expect(true)
            } else {
                Issue.record("Unexpected DigiDocError case: \(error)")
                return
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
            return
        }
    }
}
