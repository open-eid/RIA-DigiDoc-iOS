import CommonsLibMocks
import CommonsTestShared
import Foundation
import Testing

@testable import ConfigLib

struct TSLUtilTests {

    private let mockFileManager: FileManagerProtocolMock
    private let tslUtil: TSLUtilProtocol

    init() async throws {
        self.mockFileManager = FileManagerProtocolMock()
        self.tslUtil = TSLUtil(fileManager: mockFileManager)
    }

    @Test
    func setupTSLFiles_successWithValidXMLFiles() async throws {
        let fileNameURLs = [URL(fileURLWithPath: "file1.xml"), URL(fileURLWithPath: "file2.xml")]
        let fileNamePaths = fileNameURLs.map { $0.path }

        mockFileManager.contentsOfDirectoryAtHandler = { _, _, _ in
            return fileNameURLs
        }

        mockFileManager.createFileHandler = { _, _, _ in
            return true
        }

        mockFileManager.fileExistsAtPathHandler = { _, _ in
            return true
        }

        let destinationDir = URL(fileURLWithPath: "/mock/test/destination")

        try tslUtil.setupTSLFiles(
            tsls: fileNamePaths,
            destinationDir: destinationDir,
        )

        #expect(mockFileManager.copyItemAtPathCallCount == 2)
    }

    @Test
    func setupTSLFiles_nonXMLFileNotCopied() throws {
        let mockFileName = "file.txt"
        let tslFile = [URL(fileURLWithPath: mockFileName)]
        let fileNamePath = tslFile.map { $0.path }

        mockFileManager.contentsOfDirectoryAtHandler = { _, _, _ in
            return tslFile
        }

        let destinationDir = URL(fileURLWithPath: "/mock/destination")

        try tslUtil.setupTSLFiles(
            tsls: fileNamePath,
            destinationDir: destinationDir,
        )

        #expect(mockFileManager.copyItemAtPathCallCount == 0)
    }

    @Test func readSequenceNumber_success() async throws {
        let fileContents = "<root><TSLSequenceNumber>123</TSLSequenceNumber></root>"
        let tempDirectoryURL = TestFileUtil.getTemporaryDirectory(subfolder: "tslfiles")
        try FileManager.default.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true)
        let fileName = "test-\(UUID().uuidString).xml"
        let fileURL = tempDirectoryURL.appendingPathComponent(fileName)

        try fileContents.write(to: fileURL, atomically: true, encoding: .utf8)

        defer {
            try? FileManager.default.removeItem(at: fileURL)
        }

        let sequenceNumber = try tslUtil.readSequenceNumber(from: fileURL)
        #expect(sequenceNumber == 123)
    }
}
