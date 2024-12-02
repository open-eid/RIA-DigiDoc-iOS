import Foundation
import LibdigidocLibObjC

public final class DigiDocConf: DigiDocConfProtocol {

    public init() {}

}

extension DigiDocConf {
    static public func initDigiDoc() async throws {
        let digidocConf = DigiDocConfWrapper()
        digidocConf.setLogLevel(4)

        var errorDetail: ErrorDetail?

        let isInitialized = await withCheckedContinuation { continuation in
            DigiDocConfWrapper.initWithConf(digidocConf) { success, error in
                if let error = error as NSError? {
                    errorDetail = ErrorDetail(nsError: error)

                    continuation.resume(returning: false)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }

        guard isInitialized, DigiDocConfWrapper.sharedInstance() != nil else {
            throw DigiDocError.initializationFailed(errorDetail ?? ErrorDetail())
        }
    }
}
