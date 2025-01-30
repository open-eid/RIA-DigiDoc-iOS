import Foundation
import CryptoKit
import ZIPFoundation
import CoreGraphics
import Testing
import Cuckoo
import CommonsLib
import CommonsTestShared
@testable import UtilsLib

@MainActor
final class URLExtensionsTests {

    init() async throws {
        await UtilsLibAssembler.shared.initialize()
    }

    @Test
    func mimetype_successWithRegularFile() async {
        let tempFileURL = TestFileUtil.createSampleFile()

        defer {
            try? FileManager.default.removeItem(at: tempFileURL)
        }

        let mockFileUtil = MockFileUtilProtocol()

        let mimetype = await tempFileURL.mimeType(fileUtil: mockFileUtil)

        #expect("text/plain" == mimetype)
    }

    @Test
    func mimetype_successWithZipFileExtensionWhenMimeTypeNotAvailable() async {

        let mockContainer = try? TestContainerUtil.createMockContainer(
            with: ["testfile.txt": "Test content"],
            containerExtension: "zip")

        let mockFileUtil = MockFileUtilProtocol()

        stub(mockFileUtil) { fileUtil in
            when(fileUtil.getMimeTypeFromZipFile(from: any(), fileNameToFind: any()))
                .thenThrow(Archive.ArchiveError.unreadableArchive)
        }

        let mimetype = await mockContainer?.mimeType(fileUtil: mockFileUtil)

        #expect("application/zip" == mimetype)
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

            let mockMimetypeDecoder = MockMimeTypeDecoderProtocol()

            stub(mockMimetypeDecoder) { decoder in
                when(decoder.parse(xmlData: any())).thenReturn(ContainerType.ddoc)
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

            let mockMimetypeDecoder = MockMimeTypeDecoderProtocol()

            stub(mockMimetypeDecoder) { decoder in
                when(decoder.parse(xmlData: any())).thenReturn(ContainerType.none)
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

        #expect("" == md5Hash)
    }

    @Test
    func validURL_returnValidURL() throws {
        let fileUtilMock = MockFileUtilProtocol()

        let nonExistentFileLocation = URL(fileURLWithPath: "/path/to/valid/file.txt")

        stub(fileUtilMock) { fileUtil in
            when(fileUtil.getValidFileInApp(currentURL: any(URL.self))).thenReturn(nonExistentFileLocation)
        }

        let result = try nonExistentFileLocation.validURL(fileUtil: fileUtilMock)

        #expect(nonExistentFileLocation == result)
    }

    @Test
    func validURL_returnSameURLWhenFileFromAppGroup() throws {
        let fileUtilMock = MockFileUtilProtocol()

        stub(fileUtilMock) { fileUtil in
            when(fileUtil.getValidFileInApp(currentURL: any(URL.self))).thenReturn(nil)
        }

        do {
            let fileURL = try Directories.getSharedFolder().appendingPathComponent("testfolder").appendingPathComponent(
                "testFile.txt"
            )

            let testURL = URL(fileURLWithPath: fileURL.path)

            let result = try testURL.validURL(fileUtil: fileUtilMock)

            #expect(testURL == result)
        } catch {
            Issue.record("Could not get shared folder")
            return
        }
    }

    @Test
    func validURL_returnURLWhenFileFromiCloudDownloaded() throws {
        let fileUtilMock = MockFileUtilProtocol()
        stub(fileUtilMock) { fileUtil in
            when(fileUtil.getValidFileInApp(currentURL: any(URL.self))).thenReturn(nil)
            when(fileUtil.isFileFromiCloud(fileURL: any(URL.self))).thenReturn(true)
            when(fileUtil.isFileDownloadedFromiCloud(fileURL: any(URL.self))).thenReturn(true)
        }

        let testURL = URL(fileURLWithPath: "/path/to/valid/file.txt")

        let result = try testURL.validURL(fileUtil: fileUtilMock)

        #expect(testURL == result)
    }

    @Test
    func validURL_throwErrorWhenInvalidURL() throws {

        let testURL = URL(fileURLWithPath: "/path/to/valid/file.txt")

        let fileUtilMock = MockFileUtilProtocol()
        stub(fileUtilMock) { fileUtil in
            when(fileUtil.getValidFileInApp(currentURL: any(URL.self))).thenReturn(nil)
            when(fileUtil.isFileFromiCloud(fileURL: any(URL.self))).thenReturn(false)
        }

        do {
            _ = try testURL.validURL(fileUtil: fileUtilMock)
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
        let tempDirectoryURL = TestFileUtil.getTemporaryDirectory(subfolder: "TestFolder")
        let testFileURL = tempDirectoryURL.appendingPathComponent("TestFile.txt")

        try FileManager.default.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: testFileURL.path, contents: Data("Test file".utf8))

        defer {
            try? FileManager.default.removeItem(at: testFileURL)
        }

        let result = tempDirectoryURL.isFolder()

        #expect(result)
    }

    @Test
    func isFolder_returnFalseWhenPathIsFile() throws {
        let tempDirectoryURL = TestFileUtil.getTemporaryDirectory(subfolder: "TestFolder")
        let testFileURL = tempDirectoryURL.appendingPathComponent("TestFile.txt")

        try FileManager.default.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: testFileURL.path, contents: Data("Test file".utf8))

        defer {
            try? FileManager.default.removeItem(at: testFileURL)
        }

        let result = testFileURL.isFolder()

        #expect(!result)
    }

    @Test
    func folderContents_returnContentsWhenValidFolder() throws {
        let tempDirectoryURL = TestFileUtil.getTemporaryDirectory(subfolder: UUID().uuidString)
        let testFileURL = tempDirectoryURL.appendingPathComponent("TestFile.txt")

        try FileManager.default.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: testFileURL.path, contents: Data("Test file".utf8))

        defer {
            try? FileManager.default.removeItem(at: testFileURL)
        }

        let result = try tempDirectoryURL.folderContents()

        #expect(1 == result.count)
        #expect(testFileURL == result.first)
    }

    @Test
    func folderContents_returnEmptyWhenNotFolder() throws {
        let tempDirectoryURL = TestFileUtil.getTemporaryDirectory(subfolder: UUID().uuidString)
        let testFileURL = tempDirectoryURL.appendingPathComponent("TestFile.txt")

        try FileManager.default.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: testFileURL.path, contents: Data("Test file".utf8))

        defer {
            try? FileManager.default.removeItem(at: testFileURL)
        }

        let result = try testFileURL.folderContents()

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
