import Foundation

extension Collection where Element == UInt8 {
    public var hexString: String {
        self.map { String(format: "%02X", $0) }.joined(separator: " ")
    }
}
