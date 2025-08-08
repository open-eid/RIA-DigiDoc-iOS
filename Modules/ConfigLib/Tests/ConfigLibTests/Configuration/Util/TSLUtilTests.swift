import Foundation
import Testing
import CommonsLibMocks

@testable import ConfigLib

struct TSLUtilTests {

    let mockFileManager: FileManagerProtocolMock

    init() async throws {
        mockFileManager = FileManagerProtocolMock()
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

        try TSLUtil.setupTSLFiles(
            tsls: fileNamePaths,
            destinationDir: destinationDir,
            fileManager: mockFileManager
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

        try TSLUtil.setupTSLFiles(
            tsls: fileNamePath,
            destinationDir: destinationDir,
            fileManager: mockFileManager
        )

        #expect(mockFileManager.copyItemAtPathCallCount == 0)
    }
}
