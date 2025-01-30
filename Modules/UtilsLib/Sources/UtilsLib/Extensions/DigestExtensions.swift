import Foundation
import CryptoKit

extension Digest {
    public func hexString(separator: String = " ") -> String {
        self.map { String(format: "%02X", $0) }.joined(separator: separator)
    }
}
