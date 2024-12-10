import Foundation
import LibdigidocLibObjC

public struct DigiDocConf: DigiDocConfProtocol {
    static let sharedInitializer = DigiDocInitializer()

    public static func initDigiDoc() async throws {
        try await sharedInitializer.initializeDigiDoc()
    }
}

public actor DigiDocInitializer {
    private var isInitialized = false
    private var initializationError: ErrorDetail?

    private let digidocConf = DigiDocConfWrapper()

    func initializeDigiDoc() async throws {

        guard !isInitialized else {
            throw DigiDocError.alreadyInitialized
        }

        digidocConf.setLogLevel(4)

        try await initDigiDoc(conf: digidocConf)
        isInitialized = true
    }

    private func initDigiDoc(conf digiDocConf: DigiDocConfWrapper) async throws {

        var errorDetail: ErrorDetail?

        let lock = NSLock()
        let isInitialized: Bool = try await withCheckedThrowingContinuation { continuation in
            digiDocConf.initWithConf { success, error in
                lock.lock()
                defer { lock.unlock() }
                if let error = error as NSError? {
                    errorDetail = ErrorDetail(nsError: error)
                    continuation
                        .resume(
                            throwing: DigiDocError.initializationFailed(
                                errorDetail ?? ErrorDetail()
                            )
                        )
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
