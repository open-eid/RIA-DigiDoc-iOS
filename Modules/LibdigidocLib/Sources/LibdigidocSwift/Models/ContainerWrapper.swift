import Foundation
import OSLog
import LibdigidocLibObjC

public actor ContainerWrapper: Sendable {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.LibdigidocLib", category: "ContainerWrapper")

    private var dataFiles: [DataFileWrapper]
    private var signatures: [SignatureWrapper]
    private var mediatype: String?

    init(dataFiles: [DataFileWrapper] = [], signatures: [SignatureWrapper] = [], mediatype: String? = nil) {
        self.dataFiles = dataFiles
        self.signatures = signatures
        self.mediatype = mediatype
    }

    init(digiDocContainer: DigiDocContainer) {
        self.dataFiles = ContainerWrapper.getDataFiles(from: digiDocContainer)
        self.signatures = ContainerWrapper.getSignatures(from: digiDocContainer)
        self.mediatype = digiDocContainer.mediatype
    }

    public func getSignatures() -> [SignatureWrapper] {
        return signatures
    }

    public func getDataFiles() -> [DataFileWrapper] {
        return dataFiles
    }

    public func getMimetype() -> String {
        return mediatype ?? ""
    }

    public static func create(file: URL) async throws -> ContainerWrapper {
        try await withCheckedThrowingContinuation { continuation in
            DigiDocContainerWrapper.sharedInstance()?.create(file.path) { container, error in
                if let error = error as NSError? {
                    let errorMessage = "Unable to create container: \(ErrorUtil.getErrorMessage(error))"
                    continuation.resume(throwing: DigiDocError.containerCreationFailed(errorMessage))
                } else {
                    continuation.resume(returning: createContainerWrapper(digiDocContainer: container))
                }
            }
        }
    }

    public static func open(file: URL) async throws -> ContainerWrapper? {
        try await withCheckedThrowingContinuation { continuation in
            DigiDocContainerWrapper.sharedInstance()?.open(file.path) { container, error in
                if let error = error as NSError? {
                    let errorMessage = "Unable to open container: \(ErrorUtil.getErrorMessage(error))"
                    continuation.resume(throwing: DigiDocError.containerOpeningFailed(errorMessage))
                } else {
                    continuation.resume(returning: createContainerWrapper(digiDocContainer: container))
                }
            }
        }
    }

    public func addDataFiles(dataFiles: [URL?]) async throws {
        for (index, dataFileUrl) in dataFiles.enumerated() {
            guard let dataFile = dataFileUrl else { continue }
            ContainerWrapper.logger.info(
                "Adding datafile \(dataFile.lastPathComponent). \(index + 1) / \(dataFiles.count)")

            let _: Bool = try await withCheckedThrowingContinuation { continuation in
                DigiDocContainerWrapper.sharedInstance()?.addDataFile(
                    dataFile.path,
                    mimetype: "application/octet-stream") { success, error in
                        if let error = error as NSError? {
                            let errorMessage = """
                            Unable to add data files to container:
                            \(ErrorUtil.getErrorMessage(error))
                            """
                            continuation
                                .resume(throwing: DigiDocError.addingFilesToContainerFailed(errorMessage))
                        } else {
                            continuation.resume(returning: success)
                        }
                    }
            }
        }
    }

    public func save(file: URL) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            DigiDocContainerWrapper.sharedInstance()?.save(file.path) { error in
                if let error = error as NSError? {
                    let errorMessage = "Unable to save container: \(ErrorUtil.getErrorMessage(error))"
                    continuation.resume(throwing: DigiDocError.containerSavingFailed(errorMessage))
                } else {
                    continuation.resume(returning: true)
                }
            }
        }
    }

    public func getContainer() -> ContainerWrapper? {
        guard let digiDocContainerWrapper = DigiDocContainerWrapper.sharedInstance() else {
            return nil
        }

        let container = digiDocContainerWrapper.getContainer()

        return ContainerWrapper.createContainerWrapper(digiDocContainer: container)
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

    private static func createContainerWrapper(digiDocContainer: DigiDocContainer) -> ContainerWrapper {
        let dataFiles = getDataFiles(from: digiDocContainer)
        let signatures = getSignatures(from: digiDocContainer)
        let mediatype = digiDocContainer.mediatype

        return ContainerWrapper(dataFiles: dataFiles, signatures: signatures, mediatype: mediatype)
    }

    private static func getDataFiles(from container: DigiDocContainer) -> [DataFileWrapper] {
        return container.dataFiles.compactMap { dataFile in
            DataFileWrapper(fileId: dataFile.fileId,
                            fileName: dataFile.fileName,
                            fileSize: dataFile.fileSize,
                            mediaType: dataFile.mediaType)
        }
    }

    private static func getSignatures(from container: DigiDocContainer) -> [SignatureWrapper] {
        return container.signatures.compactMap { signature in
            SignatureWrapper(
                signingCert: signature.signingCert,
                timestampCert: signature.timestampCert,
                ocspCert: signature.ocspCert,
                signatureId: signature.id,
                claimedSigningTime: signature.claimedSigningTime,
                signatureMethod: signature.signatureMethod,
                dataToSign: signature.dataToSign,
                ocspProducedAt: signature.ocspProducedAt,
                timeStampTime: signature.timeStampTime,
                signedBy: signature.signedBy,
                trustedSigningTime: signature.trustedSigningTime,
                status: signatureStatusToDigiDocStatus(signature.status),
                diagnosticsInfo: signature.diagnosticsInfo
            )
        }
    }
}
