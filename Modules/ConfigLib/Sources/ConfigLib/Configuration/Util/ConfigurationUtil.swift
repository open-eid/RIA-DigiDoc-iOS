import Foundation

struct ConfigurationUtil {

    static func isSerialNewerThanCached(cachedSerial: Int?, newSerial: Int) -> Bool {
        guard let cachedSerial = cachedSerial else {
            return true
        }
        return newSerial > cachedSerial
    }

    static func isBase64(encoded: String) -> Bool {
        guard !encoded.isEmpty, let decodedData = Data(base64Encoded: encoded) else {
            return false
        }

        return encoded == decodedData.base64EncodedString()
    }
}
