import Foundation
import LibdigidocLibObjC

public struct ErrorDetail: Sendable {
    public let message: String
    public let code: Int
    public let userInfo: [String: String]

    init(message: String = "", code: Int = 0, userInfo: [String: String] = [:]) {
        self.message = message
        self.code = code
        self.userInfo = userInfo
    }

    init(nsError: NSError) {
        self.message = nsError.localizedDescription
        self.code = nsError.code
        self.userInfo = ErrorDetail
            .convertUserInfoToStringDictionary(nsError.userInfo)
    }

    init(nsError: NSError, extraInfo: [String: String]) {
        self.message = nsError.localizedDescription
        self.code = nsError.code
        self.userInfo = ErrorDetail.convertUserInfoToStringDictionary(nsError.userInfo)
            .merging(extraInfo) { (_, combined) in combined }
    }

    public var description: String {
        return """
            Error: \(self.message)
            Code: \(self.code)
            Info: \(self.userInfo)
        """
    }

    private static func convertUserInfoToStringDictionary(_ userInfo: [String: Any]) -> [String: String] {
        userInfo.mapValues { value in
            String(describing: value)
        }
    }
}
