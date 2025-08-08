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

    public var errorDetail: ErrorDetail {
        switch self {
        case .initializationFailed(let errorDetail),
                .containerCreationFailed(let errorDetail),
                .containerOpeningFailed(let errorDetail),
                .addingFilesToContainerFailed(let errorDetail),
                .containerSavingFailed(let errorDetail),
                .containerRenamingFailed(let errorDetail),
                .containerDataFileSavingFailed(let errorDetail):
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
