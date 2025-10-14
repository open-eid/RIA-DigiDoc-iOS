import Foundation
import OSLog
import FactoryKit
import LibdigidocLibObjC
import CommonsLib
import UtilsLib

public actor SignedContainer: SignedContainerProtocol {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.LibdigidocLib", category: "SignedContainer")

    private static let signedContainerLogTag: String = "SignedContainer"

    private var containerFile: URL?
    private let isExistingContainer: Bool
    private let container: ContainerWrapperProtocol
    private let timestamps: [SignatureWrapper]
    private let fileManager: FileManagerProtocol
    private let containerUtil: ContainerUtilProtocol

    public init(
        containerFile: URL? = nil,
        isExistingContainer: Bool = false,
        container: ContainerWrapperProtocol = Container.shared.containerWrapper(),
        timestamps: [SignatureWrapper] = [],
        fileManager: FileManagerProtocol,
        containerUtil: ContainerUtilProtocol
    ) {
        self.containerFile = containerFile
        self.isExistingContainer = isExistingContainer
        self.container = container
        self.timestamps = timestamps
        self.fileManager = fileManager
        self.containerUtil = containerUtil
    }

    public func getDataFiles() async -> [DataFileWrapper] {
        return await container.getDataFiles()
    }

    public func getSignatures() async -> [SignatureWrapper] {
        return await container.getSignatures()
    }

    public func getTimestamps() async -> [SignatureWrapper] {
        return timestamps
    }

    public func getContainerName() async -> String {
        return containerFile?.lastPathComponent ?? CommonsLib.Constants.Container.DefaultName
    }

    public func getContainerMimetype() async -> String {
        return await container.getMimetype()
    }

    public func getRawContainerFile() async -> URL? {
        return containerFile
    }

    public func isExistingContainer() async -> Bool {
        return isExistingContainer
    }

    public func isSigned() async -> Bool {
        return await !container.getSignatures().isEmpty
    }

    public func getSignaturesStatusCount() async -> [SignatureStatus: Int] {
        var counts: [SignatureStatus: Int] = [
            .valid: 0,
            .unknown: 0,
            .invalid: 0
        ]

        let signatures = await getSignatures()

        for signature in signatures {
            let status = signature.status
            counts[status, default: 0] += 1
        }

        return counts
    }

    public func isEmptyFileInContainer() async -> Bool {
        await getDataFiles().contains { dataFile in
            dataFile.fileSize == 0
        }
    }

    public func isCades() async -> Bool {
        let signatures = await getSignatures()

        return signatures.contains(where: { $0.format.lowercased().contains("cades") })
    }

    public func isXades() async -> Bool {
        let containerMimetype = await getContainerMimetype().lowercased()
        let signatures = await getSignatures()

        if containerMimetype.caseInsensitiveCompare(Constants.MimeType.Asics.lowercased()) == .orderedSame,
           signatures.contains(where: { $0.format.lowercased().contains("bes") }) {
            return true
        }

        return false
    }

    @discardableResult
    public func renameContainer(to newName: String) async throws -> URL {

        let fileName = newName.isEmpty ? CommonsLib.Constants.Container.DefaultName : newName

        let sanitizedFileName = fileName.sanitized()
        let normalizedPath = URL(fileURLWithPath: sanitizedFileName).standardizedPathURL

        guard let currentURL = containerFile else {
            throw DigiDocError.containerRenamingFailed(
                ErrorDetail(
                    message: "Unable to rename container. Current URL is nil",
                    userInfo: ["fileName": containerFile?.lastPathComponent ?? ""]
                )
            )
        }

        let newFileName = normalizedPath.lastPathComponent
        guard !newFileName.isEmpty else {
            throw DigiDocError.containerRenamingFailed(
                ErrorDetail(
                    message: "Unable to rename container. New filename is empty",
                    userInfo: ["fileName": currentURL.lastPathComponent]
                )
            )
        }

        let destinationURL = currentURL
            .deletingLastPathComponent()
            .appendingPathComponent(newFileName)

        let uniqueFileURL = containerUtil.getSignatureContainerFile(
            for: destinationURL,
            in: destinationURL.deletingLastPathComponent()
        )

        try fileManager.moveItem(at: currentURL, to: uniqueFileURL)

        containerFile = uniqueFileURL

        return uniqueFileURL
    }

    public func saveDataFile(dataFile: DataFileWrapper, to directory: URL?) async throws -> URL {
        guard let containerFileURL = containerFile else {
            throw DigiDocError.containerRenamingFailed(
                ErrorDetail(
                    message: "Unable to save container. No container file found.",
                    userInfo: ["fileName": containerFile?.lastPathComponent ?? "N/A"]
                )
            )
        }
        return try await container.saveDataFile(containerFile: containerFileURL, dataFile: dataFile, to: directory)
    }

    public func getNestedTimestampedContainer() async throws -> SignedContainerProtocol? {
        let isCades = await isCades()
        let isXades = await isXades()

        guard await getContainerMimetype() == CommonsLib.Constants.MimeType.Asics &&
                !isCades && !isXades else { return nil }

        let dataFiles = await getDataFiles()
        guard dataFiles.count == 1, let dataFile = dataFiles.first else { return nil }

        guard let containerFile = containerFile else { return nil }

        let containerDataFilesDir = try containerUtil.getContainerDataFilesDir(containerFile: containerFile)

        let nestedTimestampedFile = try await saveDataFile(dataFile: dataFile, to: containerDataFilesDir)

        let nestedContainer = try await ContainerWrapper(
            fileManager: fileManager
        ).open(containerFile: nestedTimestampedFile, isSivaConfirmed: true)

        let timestamps = await container.getSignatures()

        return SignedContainer(
            containerFile: containerFile,
            isExistingContainer: true,
            container: nestedContainer,
            timestamps: timestamps,
            fileManager: fileManager,
            containerUtil: containerUtil
        )
    }
}

extension SignedContainer {

    @MainActor
    public static func openOrCreate(
        dataFiles: [URL],
        containerUtil: ContainerUtilProtocol = Container.shared.containerUtil(),
        isSivaConfirmed: Bool
    ) async throws -> SignedContainerProtocol {
        logger.debug("Opening or creating container. Found \(dataFiles.count) datafile(s)")
        guard let firstFile = dataFiles.first else {
            logger.error("Unable to create or open container. First datafile is nil")
            throw DigiDocError.containerCreationFailed(
                ErrorDetail(
                    message: "Cannot create or open container. Datafiles are empty"
                )
            )
        }

        let isFirstDataFilePDF = await firstFile.isPDF() && firstFile.isSignedPDF()

        let isFirstDataFileContainer = await firstFile.isContainer() || isFirstDataFilePDF
        var containerFile: URL? = firstFile

        if (!isFirstDataFileContainer || (dataFiles.count) > 1) &&
            firstFile.pathExtension != CommonsLib.Constants.Extension.Default {
            let uniqueContainerFile = firstFile
                .deletingPathExtension()
                .appendingPathExtension(CommonsLib.Constants.Extension.Default)
            containerFile = containerUtil.getSignatureContainerFile(
                for: uniqueContainerFile,
                in: uniqueContainerFile.deletingLastPathComponent()
            )
        }

        guard let containerFile else {
            let error = isFirstDataFileContainer
                ? DigiDocError.containerOpeningFailed(
                    ErrorDetail(
                        message: "Cannot open container. Container file is nil"))
                : DigiDocError.containerCreationFailed(
                    ErrorDetail(
                        message: "Cannot create container. Container file is nil"
                    )
                )
            throw error
        }

        if dataFiles.count == 1 && isFirstDataFileContainer {
            SignedContainer.logger.debug("Opening existing container")
            return try await open(file: containerFile, isSivaConfirmed: isSivaConfirmed)
        } else {
            SignedContainer.logger.debug("Creating a new container")
            return try await create(containerFile: containerFile, dataFiles: dataFiles)
        }
    }

    private static func open(file: URL, isSivaConfirmed: Bool) async throws -> SignedContainerProtocol {
        let container = try await ContainerWrapper(
            fileManager: Container.shared.fileManager()
        ).open(containerFile: file, isSivaConfirmed: isSivaConfirmed)
        return SignedContainer(
            containerFile: file,
            isExistingContainer: true,
            container: container,
            fileManager: Container.shared.fileManager(),
            containerUtil: Container.shared.containerUtil()
        )
    }

    private static func create(
        containerFile: URL,
        dataFiles: [URL]
    ) async throws -> SignedContainerProtocol {
        let containerWrapper = ContainerWrapper(
            fileManager: Container.shared.fileManager()
        )

        try await containerWrapper.create(file: containerFile, dataFiles: dataFiles.compactMap { $0.path })

        let createdContainer = try await containerWrapper.open(containerFile: containerFile, isSivaConfirmed: true)

        return SignedContainer(
            containerFile: containerFile,
            isExistingContainer: false,
            container: createdContainer,
            fileManager: Container.shared.fileManager(),
            containerUtil: Container.shared.containerUtil()
        )
    }
}
