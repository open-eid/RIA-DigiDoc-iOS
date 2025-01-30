import Foundation

public class NameUtil {
    public static func formatName(_ name: String) -> String {
        let nameComponents = name.split(separator: ",")
            .map { $0
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: .symbols)
                .trimmingCharacters(in: .punctuationCharacters) }
            .filter { !$0.isEmpty }

        if nameComponents.count == 3 {
            let (firstName, lastName, code) = (nameComponents[0], nameComponents[1], nameComponents[2])
            return "\(lastName), \(firstName), \(code)"
        }

        return TextUtil
            .removeSlashes(nameComponents.joined(separator: ", "))
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }
}
