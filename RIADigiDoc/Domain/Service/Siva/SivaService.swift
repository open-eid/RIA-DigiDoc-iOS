import Foundation
import FactoryKit
import LibdigidocLibSwift
import CommonsLib
import UtilsLib

actor SivaService: SivaServiceProtocol {

    private let mimeTypeResolver: MimeTypeResolverProtocol
    private let fileManager: FileManagerProtocol
    private let containerUtil: ContainerUtilProtocol

    init(
        mimeTypeResolver: MimeTypeResolverProtocol,
        fileManager: FileManagerProtocol,
        containerUtil: ContainerUtilProtocol
    ) {
        self.mimeTypeResolver = mimeTypeResolver
        self.fileManager = fileManager
        self.containerUtil = containerUtil
    }

    func isSivaConfirmationNeeded(files: [URL]) async throws -> Bool {
        if files.count != 1 {
            return false
        }

        guard let file = files.first else { return false }

        let mimetype = await mimeTypeResolver.mimeType(url: file)

        return Constants.MimeType.SivaContainers.contains(mimetype) || (
            Constants.MimeType.Pdf == mimetype && file.isSignedPDF()
        )
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
