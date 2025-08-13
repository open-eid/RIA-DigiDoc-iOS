import Foundation
import OSLog
import LibdigidocLibObjC
import CommonsLib
import UtilsLib

public actor ContainerWrapper: ContainerWrapperProtocol {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.LibdigidocLib", category: "ContainerWrapper")

    private var containerURL: URL
    private var dataFiles: [DataFileWrapper]
    private var signatures: [SignatureWrapper]
    private var mediatype: String

    private let fileManager: FileManagerProtocol

    @MainActor
    private let digiDocContainerWrapper: DigiDocContainerWrapper = DigiDocContainerWrapper()

    public init(
        containerURL: URL = URL(fileURLWithPath: ""),
        dataFiles: [DataFileWrapper] = [],
        signatures: [SignatureWrapper] = [],
        mediatype: String? = nil,
        fileManager: FileManagerProtocol
    ) {
        self.containerURL = containerURL
        self.dataFiles = dataFiles
        self.signatures = signatures
        self.mediatype = mediatype ?? CommonsLib.Constants.MimeType.Default
        self.fileManager = fileManager
    }

    public func getSignatures() async -> [SignatureWrapper] {
        return await getContainer()?.signatures ?? []
    }

    public func getDataFiles() async -> [DataFileWrapper] {
        return await getContainer()?.dataFiles ?? []
    }

    public func getMimetype() async -> String {
        return await getContainer()?.mediatype ?? CommonsLib.Constants.MimeType.Container
    }

    @MainActor
    public func saveDataFile(dataFile: DataFileWrapper) async throws -> URL {
        let savedFilesDirectory = try Directories.getCacheDirectory(
            subfolder: CommonsLib.Constants.Folder.SavedFiles,
            fileManager: fileManager
        )

        var sanitizedFilename = dataFile.fileName.sanitized()
        if sanitizedFilename.isEmpty {
            sanitizedFilename = CommonsLib.Constants.Container.DefaultName
        }

        let tempSavedFileLocation = savedFilesDirectory.appendingPathComponent(sanitizedFilename)

        let lock = NSLock()
        return try await withCheckedThrowingContinuation { continuation in
            ContainerWrapper.logger.debug(
                "Saving datafile '\(sanitizedFilename)' to temporary location \(tempSavedFileLocation)"
            )

            digiDocContainerWrapper.saveDataFile(dataFile.fileId,
                                                 fileLocation: tempSavedFileLocation) { isSaved, error in
                lock.lock()
                defer { lock.unlock() }
                if error != nil {
                    if let error = error as NSError? {
                        continuation.resume(
                            throwing: DigiDocError.containerDataFileSavingFailed(
                                ErrorDetail(
                                    nsError: error,
                                    extraInfo: ["fileName": tempSavedFileLocation.lastPathComponent]
                                )
                            )
                        )
                    }
                    return
                }

                if isSaved {
                    ContainerWrapper.logger.debug("Successfully saved \(sanitizedFilename) to 'Saved Files' directory")
                    continuation.resume(returning: tempSavedFileLocation)
                } else {
                    ContainerWrapper.logger.error(
                        "Failed to save file. \(error?.localizedDescription ?? "No error to display")"
                    )
                    continuation.resume(throwing: DigiDocError.containerDataFileSavingFailed(
                        ErrorDetail(
                            message: "Unable to save datafile",
                            code: 0,
                            userInfo: ["fileName": tempSavedFileLocation.lastPathComponent])
                    ))
                }
            }
        }
    }

    @MainActor
    public func create(file: URL) async throws -> ContainerWrapper {
        let lock = NSLock()
        return try await withCheckedThrowingContinuation { continuation in
            ContainerWrapper.logger.debug("Creating container")
            digiDocContainerWrapper.create(file.path) { container, error in
                lock.lock()
                defer { lock.unlock() }
                if let error = error as NSError? {
                    continuation.resume(
                        throwing: DigiDocError.containerCreationFailed(
                            ErrorDetail(
                                nsError: error,
                                extraInfo: ["fileName": file.lastPathComponent]
                            )
                        )
                    )
                } else {
                    Task {
                        await self.setContainerURL(file)
                        await self.updateContainer(digiDocContainer: container)
                        continuation.resume(returning: self)
                    }
                }
            }
        }
    }

    @MainActor
    public func open(containerFile: URL) async throws -> ContainerWrapper {
        let lock = NSLock()
        return try await withCheckedThrowingContinuation { continuation in
            ContainerWrapper.logger.debug("Opening container file '\(containerFile.lastPathComponent)'")
            digiDocContainerWrapper.open(containerFile.path, validateOnline: true) { container, error in
                lock.lock()
                defer { lock.unlock() }
                if let error = error as NSError? {
                    continuation.resume(
                        throwing: DigiDocError.containerOpeningFailed(
                            ErrorDetail(
                                nsError: error,
                                extraInfo: ["fileName": containerFile.lastPathComponent])
                        )
                    )
                } else {
                    Task {
                        await self.setContainerURL(containerFile)
                        await self.updateContainer(digiDocContainer: container)
                        continuation.resume(returning: self)
                    }
                }
            }
        }
    }

    @MainActor
    public func addDataFiles(dataFiles: [URL?]) async throws {
        for (index, dataFileUrl) in dataFiles.enumerated() {
            guard let dataFile = dataFileUrl else { continue }
            ContainerWrapper.logger.info(
                "Adding datafile '\(dataFile.lastPathComponent)'. \(index + 1) / \(dataFiles.count)")
            try await addDataFile(dataFile: dataFile)
        }
    }

    @discardableResult
    @MainActor
    private func addDataFile(dataFile: URL) async throws -> Bool {
        let lock = NSLock()
        let mimetype = await dataFile.mimeType()
        return try await withCheckedThrowingContinuation { continuation in
            digiDocContainerWrapper.addDataFile(
                dataFile.path,
                mimetype: mimetype) { success, error in
                lock.lock()
                defer { lock.unlock() }
                if let error = error as NSError? {
                    continuation.resume(
                        throwing: DigiDocError.addingFilesToContainerFailed(
                            ErrorDetail(
                                nsError: error,
                                extraInfo: ["fileName": dataFile.lastPathComponent])
                        )
                    )
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }

    @MainActor
    public func save(file: URL) async throws -> Bool {
        let lock = NSLock()
        return try await withCheckedThrowingContinuation { continuation in
            digiDocContainerWrapper.save(file.path) { error in
                lock.lock()
                defer { lock.unlock() }
                ContainerWrapper.logger.debug("Saving container '\(file.lastPathComponent)' after creation")
                if let error = error as NSError? {
                    continuation.resume(
                        throwing: DigiDocError.containerSavingFailed(
                            ErrorDetail(
                                nsError: error,
                                extraInfo: ["fileName": file.lastPathComponent])
                        )
                    )
                } else {
                    continuation.resume(returning: true)
                }
            }
        }
    }

    @MainActor
    public func getContainer() async -> ContainerWrapper? {
        let digiDocContainer = digiDocContainerWrapper.getContainer() as DigiDocContainer?

        guard let container = digiDocContainer else { return nil }

        return await updateContainer(digiDocContainer: container)
    }

    private func signatureStatusToDigiDocStatus(_ status: DigiDocSignatureStatus) -> SignatureStatus {
        switch status {
        case .Valid:
            return .valid
        case .Warning:
            return .warning
        case .NonQSCD:
            return .nonQSCD
        case .Invalid:
            return .invalid
        case .UnknownStatus:
            return .unknown
        default:
            return .unknown
        }
    }

    @discardableResult
    private func updateContainer(digiDocContainer: DigiDocContainer) -> ContainerWrapper {
        dataFiles = getDataFiles(from: digiDocContainer)
        signatures = getSignatures(from: digiDocContainer)
        mediatype = digiDocContainer.mediatype

        return self
    }

    private func setContainerURL(_ url: URL) {
        self.containerURL = url
    }

    private func getDataFiles(from container: DigiDocContainer) -> [DataFileWrapper] {
        guard let dataFiles = container.dataFiles as? NSArray else {
            return []
        }

        return dataFiles.compactMap { item in
            guard let dataFile = item as? DigiDocDataFile else {
                ContainerWrapper.logger.error("Unexpected type: \(type(of: item))")
                return nil
            }

            return DataFileWrapper(
                fileId: dataFile.fileId,
                fileName: dataFile.fileName,
                fileSize: Int(dataFile.fileSize),
                mediaType: dataFile.mediaType
            )
        }
    }

    private func getSignatures(from container: DigiDocContainer) -> [SignatureWrapper] {
        return container.signatures.compactMap { signature in
            SignatureWrapper(
                signingCert: signature.signingCert,
                timestampCert: signature.timestampCert,
                ocspCert: signature.ocspCert,
                signatureId: signature.signatureId,
                claimedSigningTime: signature.claimedSigningTime,
                signatureMethod: signature.signatureMethod,
                ocspProducedAt: signature.ocspProducedAt,
                timeStampTime: signature.timeStampTime,
                signedBy: signature.signedBy,
                trustedSigningTime: signature.trustedSigningTime,
                roles: signature.roles as? [String] ?? [],
                city: signature.city,
                state: signature.state,
                country: signature.country,
                zipCode: signature.zipCode,
                status: signatureStatusToDigiDocStatus(signature.status),
                format: signature.format,
                messageImprint: signature.messageImprint,
                diagnosticsInfo: signature.diagnosticsInfo
            )
        }
    }
}
