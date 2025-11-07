/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
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

public enum DigiDocError: Error {
    case initializationFailed(ErrorDetail)
    case alreadyInitialized
    case containerCreationFailed(ErrorDetail)
    case containerOpeningFailed(ErrorDetail)
    case addingFilesToContainerFailed(ErrorDetail)
    case containerSavingFailed(ErrorDetail)
    case containerRenamingFailed(ErrorDetail)
    case containerDataFileSavingFailed(ErrorDetail)
    case signatureRemovingFailed(ErrorDetail)
    case dataFileRemovingFailed(ErrorDetail)
    case signatureAddingFailed(ErrorDetail)

    public var errorDetail: ErrorDetail {
        switch self {
        case .initializationFailed(let errorDetail),
                .containerCreationFailed(let errorDetail),
                .containerOpeningFailed(let errorDetail),
                .addingFilesToContainerFailed(let errorDetail),
                .containerSavingFailed(let errorDetail),
                .containerRenamingFailed(let errorDetail),
                .containerDataFileSavingFailed(let errorDetail),
                .signatureRemovingFailed(let errorDetail),
                .dataFileRemovingFailed(let errorDetail),
                .signatureAddingFailed(let errorDetail):
            return errorDetail

        case .alreadyInitialized:
            return ErrorDetail(message: "Libdigidocpp is already initialized")
        }
    }

    public var description: String {
        let detail = errorDetail
        return """
            Error: \(detail.message)
            Code: \(detail.code)
            Info: \(detail.userInfo)
        """
    }
}

extension DigiDocError: LocalizedError {
    public var errorDescription: String? {
        return errorDetail.message
    }
}
