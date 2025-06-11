import Foundation
import CryptoKit
import ZIPFoundation
import CoreGraphics
import Testing
import CommonsLib
import CommonsTestShared
@testable import UtilsLib

@MainActor
struct URLExtensionsTests {

    private let mockFileUtil: FileUtilProtocolMock!

    private let mockMimetypeDecoder: MimeTypeDecoderProtocolMock!

    private let mockFileManager: FileManagerProtocolMock!

    init() async throws {
        await UtilsLibAssembler.shared.initialize()

        mockFileUtil = FileUtilProtocolMock()
        mockMimetypeDecoder = MimeTypeDecoderProtocolMock()
        mockFileManager = FileManagerProtocolMock()
    }

    @Test
    func mimetype_successWithRegularFile() async {

        let mockFile = URL(fileURLWithPath: "/mock/path/text.txt")

        mockFileUtil.getValidFileInAppHandler = { _, _ in
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

        mockFileUtil.getMimeTypeFromZipFileHandler = { @Sendable _, _, _ in
            throw Archive.ArchiveError.unreadableArchive
        }

        let mimetype = await mockContainer?.mimeType(fileUtil: mockFileUtil)

        #expect(mimetype == "application/zip")
    }

    @Test
    func isPDF_success() async {
        let tempFileURL = TestFileUtil.getTemporaryDirectory(
            subfolder: "URLExtensionsTests"
        ).appendingPathComponent(
            "testFile.pdf"
        )

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
    func isDdoc_success() {
        do {
            let mockContainer = try TestContainerUtil.createMockContainer(
                with: ["ddoc":
                        """
                        <SignedDoc format="DIGIDOC-XML"></SignedDoc>
                      """
                ],
                containerExtension: "ddoc")

            mockMimetypeDecoder.parseHandler = { @Sendable _ in
                return ContainerType.ddoc
            }

            let isDdoc = mockContainer.isDdoc(mimeTypeDecoder: mockMimetypeDecoder)

            #expect(isDdoc)
        } catch {
            Issue.record("Could not create mock container")
            return
        }
    }

    @Test
    func isDdoc_returnFalseForUnknownContainer() {
        do {
            let mockContainer = try TestContainerUtil.createMockContainer(
                with: ["ddoc":
                        """
                        <SignedDoc format="DIGIDOC-XML"></SignedDoc>
                      """
                ],
                containerExtension: "ddoc")

            mockMimetypeDecoder.parseHandler = { @Sendable _ in
                return ContainerType.none
            }

            let isDdoc = mockContainer.isDdoc(mimeTypeDecoder: mockMimetypeDecoder)

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
        ).appendingPathComponent(
            "nonexistentFile.txt"
        )

        let md5Hash = nonexistentFileURL.md5Hash()

        #expect(md5Hash.isEmpty)
    }

    @Test
    func validURL_returnValidURL() throws {
        let nonExistentFileLocation = URL(fileURLWithPath: "/path/to/valid/file.txt")

        mockFileUtil.getValidFileInAppHandler = { @Sendable _, _ in
            return nonExistentFileLocation
        }

        let result = try nonExistentFileLocation.validURL(fileUtil: mockFileUtil)

        #expect(nonExistentFileLocation == result)
    }

    @Test
    func validURL_returnSameURLWhenFileFromAppGroup() throws {
        mockFileUtil.getValidFileInAppHandler = { @Sendable _, _ in
            return nil
        }

        do {
            let fileURL = try Directories.getSharedFolder().appendingPathComponent("testfolder").appendingPathComponent(
                "testFile.txt"
            )

            let testURL = URL(fileURLWithPath: fileURL.path)

            let result = try testURL.validURL(fileUtil: mockFileUtil)

            #expect(testURL == result)
        } catch {
            Issue.record("Could not get shared folder")
            return
        }
    }

    @Test
    func validURL_returnURLWhenFileFromiCloudDownloaded() throws {
        mockFileUtil.getValidFileInAppHandler = { @Sendable _, _ in nil }
        mockFileUtil.isFileFromiCloudHandler = { @Sendable _ in true }
        mockFileUtil.isFileDownloadedFromiCloudHandler = { @Sendable _ in true }

        let testURL = URL(fileURLWithPath: "/path/to/valid/file.txt")

        let result = try testURL.validURL(fileUtil: mockFileUtil)

        #expect(testURL == result)
    }

    @Test
    func validURL_throwErrorWhenInvalidURL() throws {

        let testURL = URL(fileURLWithPath: "/path/to/valid/file.txt")

        mockFileUtil.getValidFileInAppHandler = { @Sendable _, _ in nil }
        mockFileUtil.isFileFromiCloudHandler = { @Sendable _ in false }

        do {
            _ = try testURL.validURL(fileUtil: mockFileUtil)
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
        let testFileURL = tempDirectoryURL.appendingPathComponent("test.txt")

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
