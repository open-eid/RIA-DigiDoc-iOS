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
                .map { String(format: "%02x", $0) }
                .joined()

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
