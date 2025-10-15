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

    @MainActor
    public func getVersion() async -> String {
        return DigiDocContainerWrapper.libdigidocppVersion()
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
    public func saveDataFile(containerFile: URL, dataFile: DataFileWrapper, to directory: URL?) async throws -> URL {
        let savedFilesDirectory = try directory ?? Directories.getCacheDirectory(
            subfolder: CommonsLib.Constants.Folder.SavedFiles,
            fileManager: fileManager
        )

        let sanitizedFilename = {
            let name = dataFile.fileName.sanitized()
            return name.isEmpty ? CommonsLib.Constants.Container.DefaultName : name
        }()

        let tempSavedFileLocation = savedFilesDirectory.appendingPathComponent(sanitizedFilename)

        do {
            try await DigiDocContainerWrapper.container(
                containerFile.path,
                saveDataFile: dataFile.fileId,
                to: tempSavedFileLocation.path
            )
            ContainerWrapper.logger.debug("Successfully saved \(sanitizedFilename) to 'Saved Files' directory")
            return tempSavedFileLocation
        } catch {
            let nsError = (error as NSError?) ?? NSError(domain: "ContainerWrapper - cannot save data file", code: 2)
            throw DigiDocError.containerDataFileSavingFailed(
                ErrorDetail(nsError: nsError, extraInfo: ["fileName": tempSavedFileLocation.lastPathComponent])
            )
        }
    }

    @MainActor
    public func create(file: URL, dataFiles: [String]) async throws {
        do {
            return try await DigiDocContainerWrapper.create(file.path, withDataFilePaths: dataFiles)
        } catch {
            let nsError = (error as NSError?) ?? NSError(domain: "ContainerWrapper - cannot create container", code: 1)
            throw DigiDocError.containerCreationFailed(
                ErrorDetail(nsError: nsError, extraInfo: ["fileName": file.lastPathComponent])
            )
        }
    }

    @MainActor
    public func open(containerFile: URL, isSivaConfirmed: Bool) async throws -> ContainerWrapper {
        ContainerWrapper.logger.debug("Opening container file '\(containerFile.lastPathComponent)'")

        do {
            let container = try DigiDocContainerWrapper.open(
                containerFile.path,
                validateOnline: isSivaConfirmed
            )

            await setContainerURL(URL(fileURLWithPath: container.filePath))

            let datafiles = ContainerWrapper.getDataFiles(from: container)
            let signatures = ContainerWrapper.getSignatures(from: container)
            let mediatype = container.mediatype

            return await self.updateContainer(
                datafiles: datafiles,
                signatures: signatures,
                mediaType: mediatype
            )
        } catch {
            let nsError = (error as NSError?) ?? NSError(domain: "ContainerWrapper - cannot open container", code: 3)
            throw DigiDocError.containerOpeningFailed(
                ErrorDetail(
                    nsError: nsError,
                    extraInfo: ["fileName": containerFile.lastPathComponent])
            )
        }
    }

    @discardableResult
    @MainActor
    public func addDataFiles(containerFile: URL, dataFiles: [URL]) async throws -> Bool {
        let dataFilesPaths = dataFiles.compactMap { $0.path }
        do {
            try await DigiDocContainerWrapper.addDataFilesToContainer(
                withPath: containerFile.path,
                withDataFilePaths: dataFilesPaths
            )

            return true
        } catch {
            let nsError = (error as NSError?) ?? NSError(domain: "ContainerWrapper - cannot add data files", code: 4)
            throw DigiDocError.addingFilesToContainerFailed(
                ErrorDetail(
                    nsError: nsError
                )
            )
        }
    }

    @MainActor
    public func getContainer() async -> ContainerWrapper? {
        do {
            let digiDocContainer = try await open(containerFile: containerURL, isSivaConfirmed: true)

            let datafiles = await digiDocContainer.dataFiles
            let signatures = await digiDocContainer.signatures
            let mediatype = await digiDocContainer.mediatype

            return await updateContainer(
                datafiles: datafiles,
                signatures: signatures,
                mediaType: mediatype
            )
        } catch {
            return nil
        }
    }

    private static func signatureStatusToDigiDocStatus(_ status: DigiDocSignatureStatus) -> SignatureStatus {
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
    private func updateContainer(
        datafiles: [DataFileWrapper],
        signatures: [SignatureWrapper],
        mediaType: String?
    ) async -> ContainerWrapper {
        self.dataFiles = datafiles
        self.signatures = signatures
        self.mediatype = mediaType ?? Constants.MimeType.Container

        return self
    }

    private func setContainerURL(_ url: URL) {
        self.containerURL = url
    }

    private static func getDataFiles(from container: DigiDocContainer) -> [DataFileWrapper] {
        guard let dataFiles = container.dataFiles as? NSArray else {
            return []
        }

        return dataFiles.compactMap { item in
            guard let dataFile = item as? DigiDocDataFile else {
                ContainerWrapper.logger.error("Unexpected type: \(type(of: item))")
                return DataFileWrapper(fileId: "", fileName: "", fileSize: 0, mediaType: "")
            }

            return DataFileWrapper(
                fileId: dataFile.fileId,
                fileName: dataFile.fileName,
                fileSize: Int(dataFile.fileSize),
                mediaType: dataFile.mediaType
            )
        }
    }

    private static func getSignatures(from container: DigiDocContainer) -> [SignatureWrapper] {
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
