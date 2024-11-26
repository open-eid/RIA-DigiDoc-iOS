import Foundation
import CryptoKit
import ZIPFoundation
import CoreGraphics
import Testing
import Cuckoo
import CommonsLib
@testable import UtilsLib

@MainActor
final class URLExtensionsTests {

    init() async throws {
        await UtilsLibAssembler.shared.initialize()
    }

    @Test
    func mimetype_successWithRegularFile() {
        do {
            let fileContent = "Test file"
            let tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("testFile.txt")
            try fileContent.write(to: tempFileURL, atomically: true, encoding: .utf8)

            let mockFileUtil = MockFileUtilProtocol()

            let mimetype = tempFileURL.mimeType(fileUtil: mockFileUtil)

            #expect("text/plain" == mimetype)
        } catch {
            Issue.record("Could not create mock container")
            return
        }
    }

    @Test
    func mimetype_successWithZipFileExtensionWhenMimeTypeNotAvailable() {

        let mockContainer = try? createMockContainer(
            with: ["testfile.txt":"Test content"],
            containerExtension: "zip")

        let mockFileUtil = MockFileUtilProtocol()

        stub(mockFileUtil) { fileUtil in
            when(fileUtil.getMimeTypeFromZipFile(from: any(), fileNameToFind: any()))
                .thenThrow(Archive.ArchiveError.unreadableArchive)
        }

        let mimetype = mockContainer?.mimeType(fileUtil: mockFileUtil)

        #expect("application/zip" == mimetype)
    }

    @Test
    func isPDF_success() {
        let tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("testFile.pdf")
        let pdfURL = createTestPDF(at: tempFileURL)

        let isPDF = pdfURL.isPDF()
        let isSignedPDF = pdfURL.isSignedPDF()
        #expect(isPDF)
        #expect(!isSignedPDF)

        try? FileManager.default.removeItem(at: pdfURL)
    }

    @Test
    func isContainer_returnFalseForRegularFile() {
        let nonexistentFileURL = URL(fileURLWithPath: "/path/to/file.txt")

        let isContainer = nonexistentFileURL.isContainer()

        #expect(!isContainer)
    }

    @Test
    func isContainer_successWithContainerFile() {
        let mockContainer = try? createMockContainer(
            with: ["mimetype": Constants.MimeType.Asice],
            containerExtension: "asice")

        let isContainer = mockContainer?.isContainer() ?? false

        #expect(isContainer)
    }

    @Test
    func isDdoc_success() {
        do {
            let mockContainer = try createMockContainer(
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
            let mockContainer = try createMockContainer(
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
            let fileContent = "Test file"
            let tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("testFile.txt")
            try fileContent.write(to: tempFileURL, atomically: true, encoding: .utf8)

            let expectedMD5Hash = Insecure.MD5.hash(data: fileContent.data(using: .utf8)!)
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
        let nonexistentFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("nonexistentFile.txt")

        let md5Hash = nonexistentFileURL.md5Hash()

        #expect("" == md5Hash)
    }

    private func createMockContainer(with files: [String: String], containerExtension: String) throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
            let uniqueZipName = "\(UUID().uuidString).\(containerExtension)"
            let zipURL = tempDir.appendingPathComponent(uniqueZipName)

            do {
                let archive = try Archive(url: zipURL, accessMode: .create)
                for (fileName, fileContent) in files {
                    let fileData = fileContent.data(using: .utf8)
                    guard let fileData else {
                        preconditionFailure("Unable to get file data")
                    }
                    try archive.addEntry(
                        with: fileName,
                        type: .file,
                        uncompressedSize: Int64(fileData.count),
                        compressionMethod: .deflate,
                        provider: { position, size -> Data in
                            let positionInt = Int(position)
                            let sizeInt = Int(size)
                            return fileData.subdata(in: positionInt..<positionInt + sizeInt)
                        }
                    )
                }
            }

            return zipURL
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
