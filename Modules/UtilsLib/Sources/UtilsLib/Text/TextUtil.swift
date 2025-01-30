import Foundation

public class TextUtil {

    public static func removeSlashes(_ text: String) -> String {
        return text.replacingOccurrences(of: "\\", with: "")
    }

    public static func formatSerialNumber(_ serialNumber: String) -> String {
        let noColons = serialNumber.replacingOccurrences(of: ":", with: " ")
        return noColons.uppercased()
    }
}
