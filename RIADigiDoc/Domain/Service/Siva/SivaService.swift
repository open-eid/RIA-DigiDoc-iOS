/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

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
        let isXades = await file.isXades(fileUtil: fileUtil)

        if mimetype == Constants.MimeType.Asics {
            return await file.containsDdoc(fileUtil: fileUtil) || isCades
        }

        return Constants.MimeType.SivaContainers.contains(mimetype) && !isXades || (
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
