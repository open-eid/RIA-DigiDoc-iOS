import SwiftUI
import LibdigidocLibSwift

struct SignatureUtil: SignatureUtilProtocol {
    var languageSettings: LanguageSettingsProtocol

    func getSignatureStatusText(status: SignatureStatus) -> String {
        switch status {
            case .valid:
                return languageSettings.localized("Signature is valid")
            case .warning:
                return languageSettings.localized("Signature is valid with warnings")
            case .nonQSCD:
                return languageSettings.localized("Signature is valid non qscd")
            case .invalid:
                return languageSettings.localized("Signature is invalid")
            case .unknown:
                return languageSettings.localized("Signature is unknown")
            }
    }
}
