import Foundation
import Testing
import CommonsTestShared
import CommonsLibMocks

@testable import UtilsLib

struct ContainerUtilTests {

    private let mockFileManager: FileManagerProtocolMock!

    private let containerUtil: ContainerUtil

    init() async throws {
        mockFileManager = FileManagerProtocolMock()

        containerUtil = ContainerUtil(fileManager: mockFileManager)
    }

    @Test
    func getSignatureContainerFile_successWithFileNameWithoutChanges() async {
        let tempDirectory = URL(fileURLWithPath: "/tmp")
        let uniqueFileName = "file-\(UUID().uuidString).txt"
        let fileURL = tempDirectory.appendingPathComponent(uniqueFileName)

        let uniqueFileURL = containerUtil.getSignatureContainerFile(
            for: fileURL,
            in: tempDirectory
        )

        #expect(uniqueFileName == uniqueFileURL.lastPathComponent)
    }

    @Test
    func getSignatureContainerFile_successWithOneExistingFile() async {
        let tempDirectory = URL(fileURLWithPath: "/tmp")

        let uniqueFileName = "file-\(UUID().uuidString).txt"
        let fileURL = tempDirectory.appendingPathComponent(uniqueFileName)

        let existingPaths: Set<String> = [
            fileURL.path,
            tempDirectory.appendingPathComponent("\(uniqueFileName)").appendingPathExtension("txt").path
        ]

        mockFileManager.fileExistsHandler = { path in
            return existingPaths.contains(path)
        }

        let uniqueFileURL = containerUtil.getSignatureContainerFile(
            for: fileURL,
            in: tempDirectory
        )

        #expect(uniqueFileURL.lastPathComponent == "\(fileURL.deletingPathExtension().lastPathComponent)-1.txt")
    }

    @Test
    func getSignatureContainerFile_successWithMultipleExistingFile() async {
        let tempDirectory = URL(fileURLWithPath: "/tmp")

        let uniqueFileName = "file-\(UUID().uuidString)"
        let fileURL = tempDirectory.appendingPathComponent("\(uniqueFileName).txt")

        let existingPaths: Set<String> = [
            fileURL.path,
            tempDirectory.appendingPathComponent("\(uniqueFileName)-1").appendingPathExtension("txt").path,
            tempDirectory.appendingPathComponent("\(uniqueFileName)-2").appendingPathExtension("txt").path
        ]

        mockFileManager.fileExistsHandler = { path in
            return existingPaths.contains(path)
        }

        let uniqueFileURL = containerUtil.getSignatureContainerFile(
            for: fileURL,
            in: tempDirectory
        )

        #expect(uniqueFileURL.lastPathComponent == "\(fileURL.deletingPathExtension().lastPathComponent)-3.txt")
    }

    @Test
    func getSignatureContainerFile_successWithNoFileExtension() async {
        let tempDirectory = URL(fileURLWithPath: "/tmp")
        let uniqueFileName = "file-\(UUID().uuidString)"
        let fileURL = tempDirectory.appendingPathComponent(uniqueFileName)

        let existingPaths: Set<String> = [
            fileURL.path
        ]

        mockFileManager.fileExistsHandler = { path in
            existingPaths.contains(path)
        }

        let uniqueFileURL = containerUtil.getSignatureContainerFile(
            for: fileURL,
            in: tempDirectory
        )

        #expect(uniqueFileURL.lastPathComponent == "\(uniqueFileName)-1")
    }

    @Test
    func getSignatureContainerFile_successWithDifferentSymbols() async {
        let tempDirectory = URL(fileURLWithPath: "/tmp")

        let uniqueFileName = "file-name_with.symbols-\(UUID().uuidString).txt"
        let fileURL = tempDirectory.appendingPathComponent(uniqueFileName)

        let existingPaths: Set<String> = [
            fileURL.path,
            tempDirectory.appendingPathComponent("\(uniqueFileName)").appendingPathExtension("txt").path
        ]

        mockFileManager.fileExistsHandler = { path in
            return existingPaths.contains(path)
        }

        let uniqueFileURL = containerUtil.getSignatureContainerFile(
            for: fileURL,
            in: tempDirectory
        )

        #expect(uniqueFileURL.lastPathComponent == "\(fileURL.deletingPathExtension().lastPathComponent)-1.txt")
    }
}
