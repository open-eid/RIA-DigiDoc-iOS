import Foundation
import LibdigidoclibObjC

class ErrorUtil {
    static func getErrorMessage(_ error: NSError) -> String {
        var errorMessage = ""

        let errorCode = error.code
        let userData = error.userInfo

        if let message = userData["message"] as? String ??
            userData["NSLocalizedDescription"] as? String {
            errorMessage += message
        }

        errorMessage += ", code: \(errorCode)"

        if let causes = userData["causes"] as? [DigiDocExceptionWrapper] {
            let causesDescriptions = causes.map { $0.description }
            errorMessage += ", causes: [\(causesDescriptions.joined(separator: ", "))]"
        }

        return errorMessage
    }
}
