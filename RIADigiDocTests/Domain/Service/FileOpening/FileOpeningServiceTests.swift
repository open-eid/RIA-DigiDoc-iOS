// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import Testing
import FactoryKit
import FactoryTesting
import LibdigidocLibSwift
import CommonsLib
import UtilsLib
import CommonsTestShared
import CommonsLibMocks
import UtilsLibMocks

struct FileOpeningServiceTests {
    private let mockFileUtil: FileUtilProtocolMock
    private let mockFileManager: FileManagerProtocolMock
    private let mockFileInspector: FileInspectorProtocolMock

    private let service: FileOpeningServiceProtocol

    init() throws {
        mockFileUtil = FileUtilProtocolMock()
        mockFileManager = FileManagerProtocolMock()
        mockFileInspector = FileInspectorProtocolMock()

        service = FileOpeningService(
            fileUtil: mockFileUtil,
            fileInspector: mockFileInspector,
            fileManager: mockFileManager
        )
    }

    @Test
    func isFileSizeValid_success() async throws {
        let tempURL = URL(fileURLWithPath: mockFileManager.temporaryDirectory.appending(path: "tmp").resolvedPath)
        let tempFileURL = tempURL.appending(path: "test.txt")

        mockFileInspector.fileSizeHandler = { _ in 100 }

        let isValid = try await service.isFileSizeValid(url: tempFileURL)

        #expect(isValid)
    }

    @Test
    func isFileSizeValid_throwInvalidFileSizeErrorWhenFileSizeIsZero() async throws {
        let tempURL = URL(fileURLWithPath: mockFileManager.temporaryDirectory.appending(path: "tmp").resolvedPath)
        let tempFileURL = tempURL.appending(path: "test.txt")

        mockFileInspector.fileSizeHandler = { _ in
            throw FileOpeningError.invalidFileSize
        }

        do {
            _ = try await service.isFileSizeValid(url: tempFileURL)
            Issue.record("Expected 'invalidFileSize' error")
            return
        } catch let error {
            switch error as? FileOpeningError {
            case .invalidFileSize:
                #expect(true)
            default:
                Issue.record("Expected 'invalidFileSize' error")
                return
            }
        }

        try? FileManager.default.removeItem(at: tempFileURL)
    }

    @Test
    func getValidFiles_success() async throws {
        let tempURL = URL(fileURLWithPath: mockFileManager.temporaryDirectory.appending(path: "tmp").resolvedPath)
        let tempFileURL = tempURL.appending(path: "test.txt")
        let tempFileURL2 = tempURL.appending(path: "test2.txt")

        let urls = [tempFileURL, tempFileURL2]

        let result: Result<[URL], Error> = .success(urls)

        mockFileUtil.getValidPathHandler = { _ in tempURL }

        mockFileManager.urlsHandler = { _, _ in [tempURL] }
        mockFileManager.contentsOfDirectoryAtHandler = { _, _, _ in [tempFileURL, tempFileURL2] }
        mockFileInspector.fileSizeHandler = { _ in 100 }

        let validFiles = try await service.getValidFiles(result)

        #expect(validFiles.count == 2)
    }

    @Test
    func getValidFiles_keepsNamesThatDifferOnlyBySpecialCharactersApart() async throws {
        let tempURL = URL(fileURLWithPath: mockFileManager.temporaryDirectory.appending(path: "tmp").resolvedPath)
        let first = tempURL.appending(path: "Report: Q1.pdf")
        let second = tempURL.appending(path: "Report Q1.pdf")

        mockFileUtil.getValidPathHandler = { url in url }
        mockFileManager.urlsHandler = { _, _ in [tempURL] }
        mockFileInspector.fileSizeHandler = { _ in 100 }

        let validFiles = try await service.getValidFiles(.success([first, second]))

        #expect(validFiles.count == 2)
        #expect(validFiles[0] != validFiles[1])
    }

    @Test
    func getValidFiles_sanitizesTheCachedFileName() async throws {
        let tempURL = URL(fileURLWithPath: mockFileManager.temporaryDirectory.appending(path: "tmp").resolvedPath)
        let source = tempURL.appending(path: "Invoice?2026\\Q1*.pdf")

        mockFileUtil.getValidPathHandler = { url in url }
        mockFileManager.urlsHandler = { _, _ in [tempURL] }
        mockFileInspector.fileSizeHandler = { _ in 100 }

        let validFiles = try await service.getValidFiles(.success([source]))

        let cachedName = try #require(validFiles.first?.lastPathComponent)

        #expect(cachedName == "Invoice2026Q1.pdf")
    }

    @Test
    func getValidFiles_keepsSameNamedFilesFromDifferentFoldersApart() async throws {
        let tempURL = URL(fileURLWithPath: mockFileManager.temporaryDirectory.appending(path: "tmp").resolvedPath)
        let first = tempURL.appending(path: "folderA").appending(path: "report.pdf")
        let second = tempURL.appending(path: "folderB").appending(path: "report.pdf")

        mockFileUtil.getValidPathHandler = { url in url }
        mockFileManager.urlsHandler = { _, _ in [tempURL] }
        mockFileInspector.fileSizeHandler = { _ in 100 }

        let validFiles = try await service.getValidFiles(.success([first, second]))

        #expect(validFiles.count == 2)
        #expect(validFiles[0].lastPathComponent == "report.pdf")
        #expect(validFiles[1].lastPathComponent == "report (1).pdf")
    }

    @Test
    func getValidFiles_keepsNamesThatDifferOnlyByCaseApart() async throws {
        let tempURL = URL(fileURLWithPath: mockFileManager.temporaryDirectory.appending(path: "tmp").resolvedPath)
        let first = tempURL.appending(path: "folderA").appending(path: "report.pdf")
        let second = tempURL.appending(path: "folderB").appending(path: "Report.pdf")

        mockFileUtil.getValidPathHandler = { url in url }
        mockFileManager.urlsHandler = { _, _ in [tempURL] }
        mockFileInspector.fileSizeHandler = { _ in 100 }

        let validFiles = try await service.getValidFiles(.success([first, second]))

        #expect(validFiles.count == 2)
        #expect(validFiles[0].lastPathComponent == "report.pdf")
        #expect(validFiles[1].lastPathComponent == "Report (1).pdf")
    }

    @Test
    func getValidFiles_keepsNamesApartWhenOneOnlyLosesAPrefixWhenSanitized() async throws {
        let tempURL = URL(fileURLWithPath: mockFileManager.temporaryDirectory.appending(path: "tmp").resolvedPath)
        let first = tempURL.appending(path: "\u{2026} report.pdf")
        let second = tempURL.appending(path: "report.pdf")

        mockFileUtil.getValidPathHandler = { url in url }
        mockFileManager.urlsHandler = { _, _ in [tempURL] }
        mockFileInspector.fileSizeHandler = { _ in 100 }

        let validFiles = try await service.getValidFiles(.success([first, second]))

        let names = validFiles.map(\.lastPathComponent)

        #expect(names.count == 2)
        #expect(names[0] != names[1])
        #expect(names.map { $0.sanitized() } == names)
    }

    @Test
    func getValidFiles_keepsTheIndexSuffixWithinTheNameByteLimit() async throws {
        let tempURL = URL(fileURLWithPath: mockFileManager.temporaryDirectory.appending(path: "tmp").resolvedPath)
        let longName = String(repeating: "a", count: 1000) + ".txt"
        let first = tempURL.appending(path: "folderA").appending(path: longName)
        let second = tempURL.appending(path: "folderB").appending(path: longName)

        mockFileUtil.getValidPathHandler = { url in url }
        mockFileManager.urlsHandler = { _, _ in [tempURL] }
        mockFileInspector.fileSizeHandler = { _ in 100 }

        let validFiles = try await service.getValidFiles(.success([first, second]))

        let secondName = try #require(validFiles.last?.lastPathComponent)

        #expect(validFiles.count == 2)
        #expect(validFiles[0].lastPathComponent != secondName)
        #expect(secondName.utf8.count <= CommonsLib.Constants.File.MaxNameBytes)
        #expect(secondName.hasSuffix(" (1).txt"))
    }

    @Test
    func getValidFiles_cachesTheSameSourceFileToOneName() async throws {
        let tempURL = URL(fileURLWithPath: mockFileManager.temporaryDirectory.appending(path: "tmp").resolvedPath)
        let file = tempURL.appending(path: "report.pdf")

        mockFileUtil.getValidPathHandler = { url in url }
        mockFileManager.urlsHandler = { _, _ in [tempURL] }
        mockFileInspector.fileSizeHandler = { _ in 100 }

        let validFiles = try await service.getValidFiles(.success([file, file]))

        #expect(validFiles.count == 2)
        #expect(validFiles[0] == validFiles[1])
        #expect(validFiles[0].lastPathComponent == "report.pdf")
    }

    @Test
    func getValidFiles_truncatesNameLongerThanTheFilesystemAllows() async throws {
        let tempURL = URL(fileURLWithPath: mockFileManager.temporaryDirectory.appending(path: "tmp").resolvedPath)
        let longURL = tempURL.appending(path: String(repeating: "a", count: 1000) + ".txt")

        mockFileUtil.getValidPathHandler = { _ in longURL }
        mockFileManager.urlsHandler = { _, _ in [tempURL] }
        mockFileInspector.fileSizeHandler = { _ in 100 }

        let validFiles = try await service.getValidFiles(.success([longURL]))

        let cachedName = try #require(validFiles.first?.lastPathComponent)
        #expect(cachedName.utf8.count <= CommonsLib.Constants.File.MaxNameBytes)
        #expect(cachedName.hasSuffix(".txt"))
        #expect(cachedName.utf8.count + 11 < 255)
    }

    @Test
    func getValidFiles_successWithDuplicateFiles() async throws {
        let tempURL = URL(fileURLWithPath: mockFileManager.temporaryDirectory.appending(path: "tmp").resolvedPath)
        let tempFileURL = tempURL.appending(path: "test.txt")

        let urls = [tempFileURL, tempFileURL]

        let result: Result<[URL], Error> = .success(urls)

        mockFileUtil.getValidPathHandler = { _ in tempURL }

        mockFileManager.urlsHandler = { _, _ in [tempURL] }
        mockFileManager.contentsOfDirectoryAtHandler = { _, _, _ in [tempFileURL, tempFileURL] }
        mockFileInspector.fileSizeHandler = { _ in 100 }

        let validFiles = try await service.getValidFiles(result)

        #expect(validFiles.count == 2)
    }

    @Test
    func getValidFiles_throwErrorWhenResultUnsuccessful() async throws {
        let testError = NSError(domain: "Test", code: 1, userInfo: nil)
        let result: Result<[URL], Error> = .failure(testError)

        do {
            _ = try await service.getValidFiles(result)
            Issue.record("Expected error to be thrown")
            return
        } catch let error {
            #expect(testError.domain == (error as NSError).domain)
            #expect(testError.code == (error as NSError).code)
            #expect(testError.userInfo.keys == (error as NSError).userInfo.keys)
        }
    }

    @Test
    func openOrCreateContainer_success() async throws {
        let fileOpeningService = FileOpeningService(
            fileUtil: mockFileUtil,
            fileInspector: mockFileInspector,
            fileManager: Container.shared.fileManager()
        )
        let tempFileURL = try TestFileUtil.createSampleFile()
        let tempFileURL2 = try TestFileUtil.createSampleFile()
        let urls = [tempFileURL, tempFileURL2]

        let container = try await fileOpeningService.openOrCreateContainer(
            dataFiles: urls, isSivaConfirmed: true
        )

        let rawContainerFile = await container.getRawContainerFile()

        defer {
            try? FileManager.default.removeItem(at: tempFileURL)
            try? FileManager.default.removeItem(at: tempFileURL2)
            if let rawContainerFile {
                try? FileManager.default.removeItem(at: rawContainerFile)
            }
        }

        let containerName = await container.getContainerName()

        #expect(!containerName.isEmpty)
    }

    @Test
    func openOrCreateContainer_throwErrorWhenDatafilesEmpty() async throws {
        let emptyURLs: [URL] = []

        do {
            _ = try await service.openOrCreateContainer(
                dataFiles: emptyURLs, isSivaConfirmed: true
            )
            Issue.record("Expected 'containerCreationFailed' error")
            return
        } catch let error {
            switch error as? DigiDocError {
            case .containerCreationFailed(let errorDetail):
                #expect(errorDetail.message == "Cannot create or open container. Datafiles are empty")
            default:
                Issue.record("Expected 'containerCreationFailed' error")
                return
            }
        }
    }
}
