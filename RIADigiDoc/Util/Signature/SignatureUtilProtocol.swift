import Foundation
import LibdigidocLibSwift

/// @mockable
@MainActor
public protocol SignatureUtilProtocol: Sendable {
    func getSignatureStatusText(status: SignatureStatus) -> String
}
