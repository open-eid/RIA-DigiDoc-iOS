import Foundation
import LibdigidoclibObjC
import OSLog

public final class DigiDocConf: DigiDocConfProtocol {

    public init() {}

    static public func initDigiDoc() async throws(DigiDocError) {
        let digidocConf = DigiDocConfWrapper()
        digidocConf.setLogLevel(0)

        var errorLogMessage = "Libdigidocpp initialization error code: "

        let isInitialized = await withCheckedContinuation { continuation in
            DigiDocConfWrapper.initWithConf(digidocConf) { success, error in
                if let error = error as NSError? {
                    let errorCode = error.code
                    let userData = error.userInfo

                    if let message = userData["message"] as? String {
                        errorLogMessage += ", message: \(message)"
                    }

                    errorLogMessage += ", code: \(errorCode)"

                    if let causes = userData["causes"] as? [DigiDocExceptionWrapper] {
                        let causesDescriptions = causes.map { $0.description }
                        errorLogMessage += ", causes: [\(causesDescriptions.joined(separator: ", "))]"
                    }

                    continuation.resume(returning: false)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }

        guard isInitialized, DigiDocConfWrapper.sharedInstance() != nil else {
            throw DigiDocError.initializationFailed(errorLogMessage)
        }
    }
}
