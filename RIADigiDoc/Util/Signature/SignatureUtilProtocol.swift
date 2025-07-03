import Foundation
import LibdigidocLibSwift

/// @mockable
public protocol SignatureUtilProtocol: Sendable {
    func getSignatureStatusText(status: SignatureStatus) -> String
}
