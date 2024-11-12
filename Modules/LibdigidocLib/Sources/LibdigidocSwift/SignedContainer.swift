import Foundation
import LibdigidocLibObjC
import CommonsLib
import UtilsLib

public actor SignedContainer: Sendable, SignedContainerProtocol {
    private static let signedContainerLogTag: String = "SignedContainer"
    private static var container: ContainerWrapper?
    private static var containerFile: URL?
    private static var isExistingContainer: Bool = false

    var container: ContainerWrapper

    public init() {
        container = ContainerWrapper()
    }

    public init(container: ContainerWrapper) {
        self.container = container
    }

    public static func openOrCreate(file: URL, dataFiles: [URL?]?) async throws -> SignedContainer {
        guard let firstFile = dataFiles?.first ?? nil else { return SignedContainer() }
        let isFirstDataFileContainer = firstFile.isContainer() || (firstFile.isPDF() && firstFile.isSignedPDF())

        containerFile = file

        if (!isFirstDataFileContainer || (dataFiles?.count ?? 0) > 1) &&
            file.pathExtension != CommonsLib.Constants.Extension.Default {
            containerFile = file
                .deletingPathExtension()
                .appendingPathExtension(CommonsLib.Constants.Extension.Default)
        }

        guard let containerFile else {
            let error = isFirstDataFileContainer
            ? DigiDocError.containerOpeningFailed("Cannot open container. File is nil")
            : DigiDocError.containerCreationFailed("Cannot create container. File is nil")
            throw error
        }

        if let dataFiles = dataFiles, dataFiles.count == 1, isFirstDataFileContainer {
            isExistingContainer = true
            return try await open(file: containerFile)
        } else {
            isExistingContainer = false
            return try await create(file: containerFile, dataFiles: dataFiles)
        }
    }

    public func getDataFiles() async -> [DataFileWrapper] {
        return await container.getDataFiles()
    }

    public func getSignatures() async -> [SignatureWrapper] {
        return await container.getSignatures()
    }

    private static func open(file: URL) async throws -> SignedContainer {
        let openedContainer = try await ContainerWrapper.open(file: file)

        guard let container = openedContainer else { return SignedContainer() }

        self.container = container

        return SignedContainer(
            container: container
        )
    }

    private static func create(
        file _: URL,
        dataFiles: [URL?]?
    ) async throws -> SignedContainer {
        guard let dataFiles = dataFiles, !dataFiles.isEmpty else {
            throw DigiDocError.containerCreationFailed("Cannot create an empty container")
        }

        guard let firstFileUrl = dataFiles.first, let firstFile = firstFileUrl else {
            throw DigiDocError.containerCreationFailed("Unable to get URL of data file")
        }

        let containerWrapper = try await ContainerWrapper.create(file: firstFile)

        try await containerWrapper.addDataFiles(dataFiles: dataFiles.compactMap { $0 })

        let isSaved = try await containerWrapper.save(file: firstFile)

        guard isSaved else {
            throw DigiDocError.containerSavingFailed("Unable to save container")
        }

        let container = await containerWrapper.getContainer()

        guard let container else {
            throw DigiDocError.containerOpeningFailed("Unable to get container")
        }

        self.container = container

        return SignedContainer(container: container)
    }
}
