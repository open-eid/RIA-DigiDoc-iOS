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
    private let fileManager: FileManagerProtocol
    private let containerUtil: ContainerUtilProtocol

    public init(
        containerFile: URL? = nil,
        isExistingContainer: Bool = false,
        container: ContainerWrapperProtocol = ContainerWrapper(),
        fileManager: FileManagerProtocol,
        containerUtil: ContainerUtilProtocol
    ) {
        self.containerFile = containerFile
        self.isExistingContainer = isExistingContainer
        self.container = container
        self.fileManager = fileManager
        self.containerUtil = containerUtil
    }

    public func getDataFiles() async -> [DataFileWrapper] {
        return await container.getDataFiles()
    }

    public func getSignatures() async -> [SignatureWrapper] {
        return await container.getSignatures()
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

        let isSaved = try await container.save(file: uniqueFileURL)
        guard isSaved else {
            throw DigiDocError
                .containerSavingFailed(
                    ErrorDetail(
                        message: "Cannot finish renaming container. Unable to save the container"
                    )
                )
        }

        return uniqueFileURL
    }
}

extension SignedContainer {

    @MainActor
    public static func openOrCreate(
        dataFiles: [URL],
        containerUtil: ContainerUtilProtocol = Container.shared.containerUtil()
    ) async throws -> SignedContainer {
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
            return try await open(file: containerFile)
        } else {
            SignedContainer.logger.debug("Creating a new container")
            return try await create(containerFile: containerFile, dataFiles: dataFiles)
        }
    }

    private static func open(file: URL) async throws -> SignedContainer {
        let container = try await ContainerWrapper().open(containerFile: file)
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
    ) async throws -> SignedContainer {
        let container = try await ContainerWrapper().create(file: containerFile)

        try await container.addDataFiles(dataFiles: dataFiles.compactMap { $0 })

        let isSaved = try await container.save(file: containerFile)
        guard isSaved else {
            throw DigiDocError
            .containerSavingFailed(
                ErrorDetail(
                    message: "Cannot finish creating container. Unable to save the container"
                )
            )
        }

        let createdContainer = await container.getContainer()
        guard let createdContainer else {
            throw DigiDocError
            .containerOpeningFailed(
                ErrorDetail(
                    message: "Cannot open container after creation. Unable to get container"
                )
            )
        }

        return SignedContainer(
            containerFile: containerFile,
            isExistingContainer: false,
            container: createdContainer,
            fileManager: Container.shared.fileManager(),
            containerUtil: Container.shared.containerUtil()
        )
    }
}
