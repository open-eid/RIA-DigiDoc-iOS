import Foundation
import Testing
import CommonsLib
import CommonsTestShared
import Cuckoo
import ZIPFoundation
@testable import UtilsLib

final class FileUtilTests {

    private static let testSubFolder = "FileUtilTests"

    private let fileUtil: FileUtil

    init() async throws {
        await UtilsLibAssembler.shared.initialize()

        fileUtil = FileUtil()

        var tempDir: URL
        if #available(iOS 16.0, *) {
            tempDir = FileManager.default.temporaryDirectory.appending(
                path: "FileUtilTests",
                directoryHint: .isDirectory
            )
        } else {
            tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("FileUtilTests", isDirectory: true)
        }
        try? FileManager.default.removeItem(at: tempDir)
    }

    deinit {
        var tempDir: URL
        if #available(iOS 16.0, *) {
            tempDir = FileManager.default.temporaryDirectory.appending(
                path: "FileUtilTests",
                directoryHint: .isDirectory
            )
        } else {
            tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("FileUtilTests", isDirectory: true)
        }
        try? FileManager.default.removeItem(at: tempDir)
    }

    @Test
    func getMimeTypeFromZipFile_returnCorrectMimeType() throws {
        let asiceMimetype = CommonsLib.Constants.MimeType.Asice
        let zipFileURL = try TestContainerUtil.createMockContainer(
            with: ["mimetype": asiceMimetype],
            containerExtension: "zip")

        let fileNameToFind = "mimetype"

        let mimeType = try fileUtil.getMimeTypeFromZipFile(from: zipFileURL, fileNameToFind: fileNameToFind)

        #expect(asiceMimetype == mimeType)

        try FileManager.default.removeItem(at: zipFileURL)
    }

    @Test
    func getMimeTypeFromZipFile_returnNilWhenFileDoesNotExist() throws {
        let zipFileURL = try TestContainerUtil.createMockContainer(
            with: [:],
            containerExtension: "zip")

        let fileNameToFind = "nonexistentfile.txt"

        let mimeType = try fileUtil.getMimeTypeFromZipFile(from: zipFileURL, fileNameToFind: fileNameToFind)

        #expect(mimeType == nil)

        try FileManager.default.removeItem(at: zipFileURL)
    }
}
