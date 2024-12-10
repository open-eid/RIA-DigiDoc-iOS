import Foundation
import OSLog
import LibdigidocLibObjC
import CommonsLib
import UtilsLib

public actor SignedContainer: SignedContainerProtocol {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.LibdigidocLib", category: "SignedContainer")

    private static let signedContainerLogTag: String = "SignedContainer"

    private let containerFile: URL?
    private let isExistingContainer: Bool
    private let container: ContainerWrapper

    public init(
        containerFile: URL? = nil,
        isExistingContainer: Bool = false,
        container: ContainerWrapper = ContainerWrapper()
    ) {
        self.containerFile = containerFile
        self.isExistingContainer = isExistingContainer
        self.container = container
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
}

extension SignedContainer {

    @MainActor
    public static func openOrCreate(dataFiles: [URL]) async throws -> SignedContainer {
        logger.debug("Opening or creating container. Found \(dataFiles.count) datafile(s)")
        guard let firstFile = dataFiles.first else {
            logger.error("Unable to create or open container. First datafile is nil")
            throw DigiDocError.containerCreationFailed(
                ErrorDetail(
                    message: "Cannot create or open container. Datafiles are empty"
                )
            )
        }

        let isFirstDataFileContainer = firstFile.isContainer() || (firstFile.isPDF() && firstFile.isSignedPDF())
        var containerFile: URL? = firstFile

        if (!isFirstDataFileContainer || (dataFiles.count) > 1) &&
            firstFile.pathExtension != CommonsLib.Constants.Extension.Default {
            containerFile = firstFile
                .deletingPathExtension()
                .appendingPathExtension(CommonsLib.Constants.Extension.Default)
        }

        guard let containerFile else {
            let error = isFirstDataFileContainer
            ? DigiDocError.containerOpeningFailed(ErrorDetail(message: "Cannot open container. Container file is nil"))
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
        return SignedContainer(containerFile: file, isExistingContainer: true, container: container)
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

        return SignedContainer(containerFile: containerFile, isExistingContainer: false, container: createdContainer)
    }
}
