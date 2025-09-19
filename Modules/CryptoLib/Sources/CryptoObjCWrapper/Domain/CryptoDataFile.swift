import Foundation

@objc public class CryptoDataFile: NSObject {
    @objc public let filename: String
    @objc public let filePath: String?

    @objc public init(filename: String, filePath: String? = nil) {
        self.filename = filename
        self.filePath = filePath
    }
}
