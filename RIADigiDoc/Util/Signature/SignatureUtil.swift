import SwiftUI
import LibdigidocLibSwift

struct SignatureUtil: SignatureUtilProtocol {
    func getSignatureStatusText(status: SignatureStatus) -> String {
        switch status {
            case .valid:
                return "Signature is valid"
            case .warning:
                return "Signature is valid with warnings"
            case .nonQSCD:
                return "Signature is valid non qscd"
            case .invalid:
                return "Signature is invalid"
            case .unknown:
                return "Signature is unknown"
            }
    }
}
