import Foundation
import LibdigidocLibObjC

public final class DigiDocConf: DigiDocConfProtocol {

    public init() {}

    static public func initDigiDoc() async throws(DigiDocError) {
        let digidocConf = DigiDocConfWrapper()
        digidocConf.setLogLevel(0)

        var errorLogMessage = "Libdigidocpp initialization error: "

        let isInitialized = await withCheckedContinuation { continuation in
            DigiDocConfWrapper.initWithConf(digidocConf) { success, error in
                if let error = error as NSError? {
                    errorLogMessage += ErrorUtil.getErrorMessage(error)

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
