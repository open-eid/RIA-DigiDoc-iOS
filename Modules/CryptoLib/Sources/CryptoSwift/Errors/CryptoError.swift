// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public enum CryptoError: Error {
    case initializationFailed(CryptoErrorDetail)
    case containerCreationFailed(CryptoErrorDetail)
    case containerOpeningFailed(CryptoErrorDetail)
    case addingFilesToContainerFailed(CryptoErrorDetail)
    case containerSavingFailed(CryptoErrorDetail)
    case containerRenamingFailed(CryptoErrorDetail)
    case containerDataFileSavingFailed(CryptoErrorDetail)
    case wrongDecryptionKey

    public var errorDetail: CryptoErrorDetail {
        switch self {
        case .initializationFailed(let errorDetail),
                .containerCreationFailed(let errorDetail),
                .containerOpeningFailed(let errorDetail),
                .addingFilesToContainerFailed(let errorDetail),
                .containerSavingFailed(let errorDetail),
                .containerRenamingFailed(let errorDetail),
                .containerDataFileSavingFailed(let errorDetail):
            return errorDetail
        case .wrongDecryptionKey:
            return CryptoErrorDetail(message: "Wrong decryption key")
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

extension CryptoError: LocalizedError {
    public var errorDescription: String? {
        return errorDetail.message
    }
}
