import Foundation
import Testing
@testable import UtilsLib

struct ContainerUtilTests {

    var tempDirectory: URL!

    init() async throws {
        await UtilsLibAssembler.shared.initialize()

        let fileManager = FileManager.default
        tempDirectory = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? fileManager.createDirectory(at: tempDirectory, withIntermediateDirectories: true, attributes: nil)
    }

    @Test
    func getSignatureContainerFile_successWithFileNameWithoutChanges() {
        let uniqueFileName = "file-\(UUID().uuidString).txt"
        let fileURL = tempDirectory.appendingPathComponent(uniqueFileName)

        let uniqueFileURL = ContainerUtil.getSignatureContainerFile(for: fileURL, in: tempDirectory)

        #expect(uniqueFileName == uniqueFileURL.lastPathComponent)
    }

    @Test
    func getSignatureContainerFile_successWithOneExistingFile() {
        let uniqueFileName = "file-\(UUID().uuidString).txt"
        let fileURL = tempDirectory.appendingPathComponent(uniqueFileName)
        try? "Test content".write(to: fileURL, atomically: true, encoding: .utf8)

        let uniqueFileURL = ContainerUtil.getSignatureContainerFile(for: fileURL, in: tempDirectory)

        #expect(uniqueFileURL.lastPathComponent == "\(fileURL.deletingPathExtension().lastPathComponent)-1.txt")
    }

    @Test
    func getSignatureContainerFile_successWithMultipleExistingFile() {
        let uniqueFileName = "file-\(UUID().uuidString)"
        let fileURL = tempDirectory.appendingPathComponent("\(uniqueFileName).txt")
        try? "Test content".write(to: fileURL, atomically: true, encoding: .utf8)
        try? "Test content".write(
            to: tempDirectory.appendingPathComponent("\(uniqueFileName)-1.txt"),
            atomically: true,
            encoding: .utf8
        )
        try? "Test content".write(
            to: tempDirectory.appendingPathComponent("\(uniqueFileName)-2.txt"),
            atomically: true,
            encoding: .utf8
        )

        let uniqueFileURL = ContainerUtil.getSignatureContainerFile(for: fileURL, in: tempDirectory)

        #expect(uniqueFileURL.lastPathComponent == "\(fileURL.deletingPathExtension().lastPathComponent)-3.txt")
    }

    @Test
    func getSignatureContainerFile_successWithNoFileExtension() {
        let uniqueFileName = "file-\(UUID().uuidString)"
        let fileURL = tempDirectory.appendingPathComponent(uniqueFileName)
        try? "Test content".write(to: fileURL, atomically: true, encoding: .utf8)

        let uniqueFileURL = ContainerUtil.getSignatureContainerFile(for: fileURL, in: tempDirectory)

        #expect(uniqueFileURL.lastPathComponent == "\(uniqueFileName)-1")
    }

    @Test
    func getSignatureContainerFile_successWithDifferentSymbols() {
        let uniqueFileName = "file-name_with.symbols-\(UUID().uuidString).txt"
        let fileURL = tempDirectory.appendingPathComponent(uniqueFileName)
        try? "Test content".write(to: fileURL, atomically: true, encoding: .utf8)

        let uniqueFileURL = ContainerUtil.getSignatureContainerFile(for: fileURL, in: tempDirectory)

        #expect(uniqueFileURL.lastPathComponent == "\(fileURL.deletingPathExtension().lastPathComponent)-1.txt")
    }
}
