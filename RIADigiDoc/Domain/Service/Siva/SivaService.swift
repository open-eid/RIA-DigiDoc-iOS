import Foundation
import FactoryKit
import LibdigidocLibSwift
import CommonsLib
import UtilsLib

actor SivaService: SivaServiceProtocol {

    private let mimeTypeResolver: MimeTypeResolverProtocol
    private let fileManager: FileManagerProtocol
    private let containerUtil: ContainerUtilProtocol
    private let fileUtil: FileUtilProtocol

    init(
        mimeTypeResolver: MimeTypeResolverProtocol,
        fileManager: FileManagerProtocol,
        containerUtil: ContainerUtilProtocol,
        fileUtil: FileUtilProtocol
    ) {
        self.mimeTypeResolver = mimeTypeResolver
        self.fileManager = fileManager
        self.containerUtil = containerUtil
        self.fileUtil = fileUtil
    }

    func isSivaConfirmationNeeded(files: [URL]) async -> Bool {
        if files.count != 1 {
            return false
        }

        guard let file = files.first else { return false }

        let mimetype = await mimeTypeResolver.mimeType(url: file)

        let isCades = await file.isCades(fileUtil: fileUtil)

        return Constants.MimeType.SivaContainers.contains(mimetype) || (
            Constants.MimeType.Pdf == mimetype && file.isSignedPDF()
        ) || isCades
    }

    func isTimestampedContainer(signedContainer: SignedContainerProtocol) async -> Bool {
        let isOneDataFileInContainer = await signedContainer.getDataFiles().count == 1
        let isAsicsMimeType = await signedContainer.getContainerMimetype() == Constants.MimeType.Asics
        let isTimeStampTokenSignatureMethod = await signedContainer.getSignatures().first?.format == "TimeStampToken"

        return isOneDataFileInContainer &&
        isAsicsMimeType &&
        isTimeStampTokenSignatureMethod
    }

    func getTimestampedContainer(parentContainer: SignedContainerProtocol) async throws -> SignedContainerProtocol {
        guard let container = try await parentContainer.getNestedTimestampedContainer() else {
            throw DigiDocError.containerOpeningFailed(
                ErrorDetail(message: "Unable to open nested timestamped container")
            )
        }
        return container
    }
}
