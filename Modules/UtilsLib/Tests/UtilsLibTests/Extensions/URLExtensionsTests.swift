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
import CryptoKit
import ZIPFoundation
import CoreGraphics
import Testing
import CommonsLib
import CommonsTestShared
import CommonsLibMocks
import UtilsLibMocks

@testable import UtilsLib

@MainActor
struct URLExtensionsTests {

    private let mockFileUtil: FileUtilProtocolMock!

    private let mockMimetypeDecoder: MimeTypeDecoderProtocolMock!

    private let mockFileManager: FileManagerProtocolMock!

    init() async throws {
        mockFileUtil = FileUtilProtocolMock()
        mockMimetypeDecoder = MimeTypeDecoderProtocolMock()
        mockFileManager = FileManagerProtocolMock()
    }

    @Test
    func mimetype_successWithRegularFile() async {

        let mockFile = URL(fileURLWithPath: "/mock/path/text.txt")

        mockFileUtil.getValidPathHandler = { _ in
            return mockFile
        }

        let mimetype = await mockFile.mimeType(fileUtil: mockFileUtil)

        #expect(mimetype == "text/plain")
    }

    @Test
    func mimetype_successWithZipFileExtensionWhenMimeTypeNotAvailable() async {

        let mockContainer = try? TestContainerUtil.createMockContainer(
            with: ["testfile.txt": "Test content"],
            containerExtension: "zip")

        mockFileUtil.getFileFromZipFileHandler = { _, _ in
            throw Archive.ArchiveError.unreadableArchive
        }

        let mimetype = await mockContainer?.mimeType(fileUtil: mockFileUtil)

        #expect(mimetype == "application/zip")
    }

    @Test
    func isPDF_success() async {
        let tempFileURL = TestFileUtil.getTemporaryDirectory(
            subfolder: "URLExtensionsTests"
        ).appending(path: "testFile.pdf")

        let pdfURL = createTestPDF(at: tempFileURL)

        let isPDF = await pdfURL.isPDF()
        let isSignedPDF = pdfURL.isSignedPDF()
        #expect(isPDF)
        #expect(!isSignedPDF)

        try? FileManager.default.removeItem(at: pdfURL)
    }

    @Test
    func isContainer_returnFalseForRegularFile() async {
        let nonexistentFileURL = URL(fileURLWithPath: "/path/to/file.txt")

        let isContainer = await nonexistentFileURL.isContainer()

        #expect(!isContainer)
    }

    @Test
    func isContainer_successWithContainerFile() async {
        let mockContainer = try? TestContainerUtil.createMockContainer(
            with: ["mimetype": Constants.MimeType.Asice],
            containerExtension: "asice")

        let isContainer = await mockContainer?.isContainer() ?? false

        #expect(isContainer)
    }

    @Test
    func isDdoc_success() async {
        do {
            let mockContainer = try TestContainerUtil.createMockContainer(
                with: ["ddoc":
                        """
                        <SignedDoc format="DIGIDOC-XML"></SignedDoc>
                      """
                ],
                containerExtension: "ddoc")

            mockMimetypeDecoder.parseHandler = { _ in
                return ContainerType.ddoc
            }

            let isDdoc = await mockContainer.isDdoc(mimeTypeDecoder: mockMimetypeDecoder)

            #expect(isDdoc)
        } catch {
            Issue.record("Could not create mock container")
            return
        }
    }

    @Test
    func isDdoc_returnFalseForUnknownContainer() async {
        do {
            let mockContainer = try TestContainerUtil.createMockContainer(
                with: ["ddoc":
                        """
                        <SignedDoc format="DIGIDOC-XML"></SignedDoc>
                      """
                ],
                containerExtension: "ddoc")

            mockMimetypeDecoder.parseHandler = { _ in
                return ContainerType.none
            }

            let isDdoc = await mockContainer.isDdoc(mimeTypeDecoder: mockMimetypeDecoder)

            #expect(!isDdoc)
        } catch {
            Issue.record("Could not create mock container")
            return
        }
    }

    @Test
    func md5Hash_success() {
        do {
            let tempFileURL = TestFileUtil.createSampleFile()

            let expectedMD5Hash = Insecure.MD5.hash(data: try Data(contentsOf: tempFileURL))
                .hexString(separator: "")

            let md5Hash = tempFileURL.md5Hash()

            #expect(expectedMD5Hash == md5Hash)

            try FileManager.default.removeItem(at: tempFileURL)
        } catch {
            Issue.record("Could not write to or delete temp file")
            return
        }
    }

    @Test
    func md5Hash_returnEmptyStringIfFileDoesNotExist() {
        let nonexistentFileURL = TestFileUtil.getTemporaryDirectory(
            subfolder: "URLExtensionsTests"
        ).appending(path: "nonexistentFile.txt")

        let md5Hash = nonexistentFileURL.md5Hash()

        #expect(md5Hash.isEmpty)
    }

    @Test
    func validURL_returnValidURL() async throws {
        let nonExistentFileLocation = URL(fileURLWithPath: "/path/to/valid/file.txt")

        mockFileUtil.getValidPathHandler = { _ in
            return nonExistentFileLocation
        }

        let result = try await nonExistentFileLocation.validURL(fileUtil: mockFileUtil)

        #expect(nonExistentFileLocation == result)
    }

    @Test
    func validURL_returnValidAppGroupURL() async throws {
        let mockFile = URL(fileURLWithPath: "/path/to/valid/file.txt")

        mockFileUtil.getValidPathHandler = { _ in
            return nil
        }

        mockFileUtil.getFileUrlFromAppGroupHandler = { _, _ in mockFile }

        let result = try await mockFile.validURL(fileUtil: mockFileUtil)

        #expect(mockFile == result)
    }

    @Test
    func validURL_returnURLWhenFileFromiCloudDownloaded() async throws {
        mockFileUtil.getValidPathHandler = { _ in nil }
        mockFileUtil.isFileFromiCloudHandler = { _ in true }
        mockFileUtil.isFileDownloadedFromiCloudHandler = { _ in true }

        let testURL = URL(fileURLWithPath: "/path/to/valid/file.txt")

        let result = try await testURL.validURL(fileUtil: mockFileUtil)

        #expect(testURL == result)
    }

    @Test
    func validURL_throwErrorWhenInvalidURL() async throws {

        let testURL = URL(fileURLWithPath: "/path/to/valid/file.txt")

        mockFileUtil.getValidPathHandler = { _ in nil }
        mockFileUtil.isFileFromiCloudHandler = { _ in false }

        do {
            _ = try await testURL.validURL(fileUtil: mockFileUtil)
            Issue.record("Expected .badURL error")
            return
        } catch let error as URLError {
            #expect(error.code == .badURL)
        } catch {
            Issue.record("Expected .badURL error")
            return
        }
    }

    @Test
    func isFolder_returnTrueWhenPathIsDirectory() throws {
        let tempDirectoryURL = URL(fileURLWithPath: "/mock/path")

        mockFileManager.fileExistsAtPathHandler = { _, isDirectory in
            if let dirPointer = isDirectory {
                dirPointer.pointee = true
            }
            return true
        }

        let result = tempDirectoryURL.isFolder(fileManager: mockFileManager)

        #expect(result)
    }

    @Test
    func isFolder_returnFalseWhenPathIsFile() throws {
        let tempFileURL = URL(fileURLWithPath: "/mock/path/test.txt")

        mockFileManager.fileExistsAtPathHandler = { _, isDirectory in
            if let dirPointer = isDirectory {
                dirPointer.pointee = false
            }
            return true
        }

        let result = tempFileURL.isFolder(fileManager: mockFileManager)

        #expect(!result)
    }

    @Test
    func folderContents_returnContentsWhenValidFolder() throws {
        let tempDirectoryURL = URL(fileURLWithPath: "/mock/path")
        let testFileURL = tempDirectoryURL.appending(path: "test.txt")

        mockFileManager.fileExistsAtPathHandler = { _, isDirectory in
            if let dirPointer = isDirectory {
                dirPointer.pointee = true
            }
            return true
        }

        mockFileManager.contentsOfDirectoryAtHandler  = { _, _, _ in
            return [
                testFileURL,
                URL(fileURLWithPath: "/mock/path/test2.txt")
            ]
        }

        let result = try tempDirectoryURL.folderContents(fileManager: mockFileManager)

        #expect(result.count == 2)
        #expect(testFileURL == result.first)
    }

    @Test
    func folderContents_returnEmptyWhenNotFolder() throws {
        let tempFileURL = URL(fileURLWithPath: "/mock/path/test.txt")

        mockFileManager.fileExistsAtPathHandler = { _, isDirectory in
            if let dirPointer = isDirectory {
                dirPointer.pointee = false
            }
            return true
        }

        mockFileManager.contentsOfDirectoryAtHandler  = { _, _, _ in
            return [
                tempFileURL,
                URL(fileURLWithPath: "/mock/path/test2.txt")
            ]
        }

        let result = try tempFileURL.folderContents(fileManager: mockFileManager)

        #expect(result.isEmpty)
    }

    @Test
    func standardizedPathURL_success() {
        let url = URL(fileURLWithPath: "/tmp/folder/file.txt")
        let standardized = url.resolvedPath
        #expect(standardized == "/tmp/folder/file.txt")
    }

    @Test
    func standardizedPathURL_removeRedundantSlashes() {
        let url = URL(fileURLWithPath: "/tmp//folder///file.txt")
        let standardized = url.resolvedPath
        #expect(standardized == "/tmp/folder/file.txt")
    }

    @Test
    func standardizedPathURL_resolveDotComponents() {
        let url = URL(fileURLWithPath: "/tmp/folder/../file.txt")
        let standardized = url.resolvedPath
        #expect(standardized == "/tmp/file.txt")
    }

    @Test
    func standardizedPathURL_trimTrailingSlashFromFile() {
        let url = URL(fileURLWithPath: "/tmp/folder/file.txt/")
        let standardized = url.resolvedPath
        #expect(standardized == "/tmp/folder/file.txt")
    }

    @Test
    func standardizedPathURL_emptyPathResolvesToCurrentDirectory() {
        let url = URL(fileURLWithPath: "")
        let standardized = url.resolvedPath
        let expectedPath = FileManager.default.currentDirectoryPath
        #expect(standardized == expectedPath)
    }

    @Test
    func isCades_successReturningTrue() async throws {
        let mockFile = URL(fileURLWithPath: "/mock/path/testFile.p7s")

        let mockContainer = try TestContainerUtil.createMockContainer(
            with: [mockFile.lastPathComponent: "Test content"],
            containerExtension: "asice")

        mockFileUtil.getFileFromZipFileHandler = { _, _ in
            return mockFile
        }

        defer {
            try? FileManager.default.removeItem(at: mockContainer)
        }

        let isCades = await mockContainer.isCades(fileUtil: mockFileUtil)

        #expect(isCades)
    }

    @Test
    func isCades_successReturningFalse() async {
        let mockContainer = URL(fileURLWithPath: "/mock/path/regularContainer.asice")

        mockFileUtil.getFileFromZipFileHandler = { _, _ in
            return nil
        }

        let isCades = await mockContainer.isCades(fileUtil: mockFileUtil)

        #expect(!isCades)
    }

    @Test
    func isXades_successReturningTrue() async throws {
        let mockFile = URL(fileURLWithPath: "/mock/path/signatures.xml")

        let mockContainer = try TestContainerUtil.createMockContainer(
            with: [mockFile.lastPathComponent: "Test content"],
            containerExtension: "asics")

        mockFileUtil.getFileFromZipFileHandler = { _, _ in
            return mockFile
        }

        defer {
            try? FileManager.default.removeItem(at: mockContainer)
        }

        let isXades = await mockContainer.isXades(fileUtil: mockFileUtil)

        #expect(isXades)
    }

    @Test
    func isXades_successReturningFalse() async {
        let mockContainer = URL(fileURLWithPath: "/mock/path/regularContainer.asice")

        mockFileUtil.getFileFromZipFileHandler = { _, _ in
            return nil
        }

        let isXades = await mockContainer.isXades(fileUtil: mockFileUtil)

        #expect(!isXades)
    }

    private func createTestPDF(at url: URL) -> URL {
        var pageSize = CGRect(x: 0, y: 0, width: 100, height: 100)

        guard let pdfContext = CGContext(url as CFURL, mediaBox: &pageSize, nil) else {
            preconditionFailure("Unable to create a test PDF file")
        }

        pdfContext.beginPDFPage(nil)

        let text = "Test PDF file"

        let attributedText = NSAttributedString(string: text, attributes: nil)
        let textRect = CGRect(x: 50, y: 1000, width: pageSize.width - 100, height: 50)
        attributedText.draw(in: textRect)

        pdfContext.endPDFPage()
        pdfContext.closePDF()

        return url
    }
}
