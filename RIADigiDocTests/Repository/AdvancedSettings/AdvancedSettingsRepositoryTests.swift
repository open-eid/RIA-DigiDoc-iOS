import CommonsLib
import CommonsLibMocks
import CommonsTestShared
import Foundation
import Testing

struct AdvancedSettingsRepositoryTests {
    private let mockFileManager: FileManagerProtocolMock
    private let mockCertificateUtil: CertificateUtilProtocolMock

    private let repository: AdvancedSettingsRepositoryProtocol!

    init() async throws {
        mockFileManager = FileManagerProtocolMock()
        mockCertificateUtil = CertificateUtilProtocolMock()

        repository = AdvancedSettingsRepository(
            fileManager: mockFileManager,
            certificateUtil: mockCertificateUtil
        )
    }

    // MARK: - GetCertificate Tests

    @Test
    func getCertificate_success() async throws {
        let sampleFileURL = TestCertificateUtil.createSampleCertFile()
        let sampleFileBaseName = sampleFileURL.deletingPathExtension().lastPathComponent
        let sampleFolder = sampleFileURL
            .deletingPathExtension().deletingPathExtension().lastPathComponent
        defer {
            try? FileManager.default.removeItem(at: sampleFileURL)
        }

        mockFileManager.contentsOfDirectoryAtHandler = { _, _, _ in
            return [
                sampleFileURL
            ]
        }
        mockFileManager.fileExistsHandler = { _ in
            return true
        }

        let certificateData = await repository.getCertificate(
            certificateFolder: sampleFolder,
            certificateBaseName: sampleFileBaseName,
        )

        #expect(certificateData != nil)
    }

    @Test
    func getCertificate_returnsNilWhenFileDoesNotExist() async throws {
        let sampleFileBaseName = "test-name"
        let sampleFolder = "test-folder"

        mockFileManager.contentsOfDirectoryAtHandler = { _, _, _ in
            return [
            ]
        }
        mockFileManager.fileExistsHandler = { _ in
            return false
        }

        let certificateData = await repository.getCertificate(
            certificateFolder: sampleFolder,
            certificateBaseName: sampleFileBaseName,
        )

        #expect(certificateData == nil)
    }

    @Test
    func getCertificate_doesNotThrowWhenGetCertificateFileURLThrows() async throws {
        let sampleFileURL = TestCertificateUtil.createSampleCertFile()
        let sampleFileBaseName = sampleFileURL.deletingPathExtension().lastPathComponent
        let sampleFolder = sampleFileURL
            .deletingPathExtension().deletingPathExtension().lastPathComponent
        defer {
            try? FileManager.default.removeItem(at: sampleFileURL)
        }

        mockFileManager.fileExistsHandler = { _ in
            return true
        }
        mockFileManager.contentsOfDirectoryAtHandler = { _, _, _ in
            throw NSError(domain: "TestError", code: 1, userInfo: nil)
        }

        await #expect(throws: Never.self) {
            let certificateData = await repository.getCertificate(
                certificateFolder: sampleFolder,
                certificateBaseName: sampleFileBaseName,
            )
            #expect(certificateData == nil)
        }
    }

    // MARK: - importCertificate tests

    @Test
    func importCertificate_success() async throws {
        let sampleFileURL = TestCertificateUtil.createSampleCertFile(
            subfolder: BundleUtil.getBundleIdentifier()
        )
        let sampleFileBaseName = sampleFileURL.deletingPathExtension().lastPathComponent
        let sampleFileFolder = sampleFileURL.deletingLastPathComponent().deletingLastPathComponent()
        defer {
            try? FileManager.default.removeItem(at: sampleFileURL)
        }

        mockFileManager.urlHandler = { _, _, _, _ in
            return sampleFileFolder
        }

        let certificateData = await repository.importCertificate(
            from: sampleFileURL,
            certificateFolder: "",
            certificateBaseName: sampleFileBaseName,
        )

        #expect(certificateData != nil)
        #expect(mockFileManager.copyItemCallCount == 1)
    }

    @Test
    func importCertificate_doesNotThrowWhenCreateDirectoryThrows() async throws {
        let sampleFileURL = TestCertificateUtil.createSampleCertFile()
        let sampleFileBaseName = sampleFileURL.deletingPathExtension().lastPathComponent
        defer {
            try? FileManager.default.removeItem(at: sampleFileURL)
        }

        mockFileManager.createDirectoryHandler = { _, _, _ in
            throw NSError(domain: "TestError", code: 1, userInfo: nil)
        }

        await #expect(throws: Never.self) {
            let certificateData = await repository.importCertificate(
                from: sampleFileURL,
                certificateFolder: "test-folder",
                certificateBaseName: sampleFileBaseName,
            )
            #expect(certificateData == nil)
        }
    }

    @Test
    func importCertificate_doesNotThrowWhenRemoveAllCertFilesThrows() async throws {
        let sampleFileURL = TestCertificateUtil.createSampleCertFile()
        let sampleFileBaseName = sampleFileURL.deletingPathExtension().lastPathComponent
        defer {
            try? FileManager.default.removeItem(at: sampleFileURL)
        }

        mockFileManager.contentsOfDirectoryAtHandler = { _, _, _ in
            return [
                sampleFileURL
            ]
        }
        mockFileManager.fileExistsHandler = { _ in
            return true
        }
        mockFileManager.removeItemHandler = { _ in
            throw NSError(domain: "TestError", code: 1, userInfo: nil)
        }

        await #expect(throws: Never.self) {
            let certificateData = await repository.importCertificate(
                from: sampleFileURL,
                certificateFolder: "test-folder",
                certificateBaseName: sampleFileBaseName,
            )
            #expect(certificateData == nil)
        }
    }
}
