import Foundation
import Testing
import CommonsLib
import CommonsTestShared
import Cuckoo
import ZIPFoundation
@testable import UtilsLib

final class FileUtilTests {

    private static let testSubFolder = "FileUtilTests"

    private let fileUtil: FileUtilProtocol

    init() async throws {
        await UtilsLibAssembler.shared.initialize()

        fileUtil = FileUtil()

        let tempDir = TestFileUtil.getTemporaryDirectory(subfolder: "FileUtilTests")
        try? FileManager.default.removeItem(at: tempDir)
    }

    deinit {
        let tempDir = TestFileUtil.getTemporaryDirectory(subfolder: "FileUtilTests")
        try? FileManager.default.removeItem(at: tempDir)
    }

    @Test
    func getMimeTypeFromZipFile_returnCorrectMimeType() async throws {
        let asiceMimetype = CommonsLib.Constants.MimeType.Asice
        let zipFileURL = try TestContainerUtil.createMockContainer(
            with: ["mimetype": asiceMimetype],
            containerExtension: "zip")

        let fileNameToFind = "mimetype"

        let mimeType = try await fileUtil.getMimeTypeFromZipFile(from: zipFileURL, fileNameToFind: fileNameToFind)

        #expect(asiceMimetype == mimeType)

        try FileManager.default.removeItem(at: zipFileURL)
    }

    @Test
    func getMimeTypeFromZipFile_returnNilWhenFileDoesNotExist() async throws {
        let zipFileURL = try TestContainerUtil.createMockContainer(
            with: [:],
            containerExtension: "zip")

        let fileNameToFind = "nonexistentfile.txt"

        let mimeType = try await fileUtil.getMimeTypeFromZipFile(from: zipFileURL, fileNameToFind: fileNameToFind)

        #expect(mimeType == nil)

        try FileManager.default.removeItem(at: zipFileURL)
    }
}
