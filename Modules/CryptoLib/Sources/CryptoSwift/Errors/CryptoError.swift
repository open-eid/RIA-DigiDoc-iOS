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

public enum CryptoError: Error {
    case initializationFailed(CryptoErrorDetail)
    case containerCreationFailed(CryptoErrorDetail)
    case containerOpeningFailed(CryptoErrorDetail)
    case addingFilesToContainerFailed(CryptoErrorDetail)
    case containerSavingFailed(CryptoErrorDetail)
    case containerRenamingFailed(CryptoErrorDetail)
    case containerDataFileSavingFailed(CryptoErrorDetail)
    case signatureRemovingFailed(CryptoErrorDetail)

    public var errorDetail: CryptoErrorDetail {
        switch self {
        case .initializationFailed(let errorDetail),
                .containerCreationFailed(let errorDetail),
                .containerOpeningFailed(let errorDetail),
                .addingFilesToContainerFailed(let errorDetail),
                .containerSavingFailed(let errorDetail),
                .containerRenamingFailed(let errorDetail),
                .containerDataFileSavingFailed(let errorDetail),
                .signatureRemovingFailed(let errorDetail):
            return errorDetail
        }
    }
}
