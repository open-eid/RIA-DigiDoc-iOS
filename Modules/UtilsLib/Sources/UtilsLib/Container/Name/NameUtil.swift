import Foundation

public struct NameUtil: NameUtilProtocol {

    public func formatName(_ nameComponents: [String]) -> String {
        let formattedNameComponents: String

        if nameComponents.count == 3 {
            let lastname = nameComponents[0]
            let firstname = nameComponents[1]
            let code = nameComponents[2]

            formattedNameComponents = "\(capitalizeName(firstname)) \(capitalizeName(lastname)), \(code)"
                .trimmingCharacters(in: .whitespaces)
        } else {
            formattedNameComponents = nameComponents.isEmpty
            ? ""
            : nameComponents
                .map(capitalizeName(_:))
                .joined(separator: ", ")
                .trimmingCharacters(in: .whitespaces)
        }

        return cleanString(formattedNameComponents)
    }

    public func formatName(_ name: String) -> String {
        let components = name.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        return formatName(components)
    }

    public func formatName(surname: String?, givenName: String?, identifier: String?) -> String {
        let components = [surname, givenName, identifier].compactMap { $0 }
        return formatName(components)
    }

    public func formatCompanyName(identifier: String?, serialNumber: String?) -> String {
        let components = [identifier, serialNumber]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return components.joined(separator: ", ")
    }

    private func capitalizeName(_ name: String) -> String {
        let lowercaseName = name.lowercased()
        let pattern = #"([\p{L}\d])([\p{L}\d]*)"#

        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.useUnicodeWordBoundaries]) else {
            return lowercaseName
        }

        let range = NSRange(lowercaseName.startIndex..., in: lowercaseName)
        var result = lowercaseName
        var offset = 0

        regex.enumerateMatches(in: lowercaseName, options: [], range: range) { match, _, _ in
            guard let match = match else { return }
            if let firstRange = Range(match.range(at: 1), in: lowercaseName),
               let restRange = Range(match.range(at: 2), in: lowercaseName) {

                let first = lowercaseName[firstRange].uppercased()
                let rest = String(lowercaseName[restRange])
                let fullRange = match.range

                let replacement = first + rest
                let nsRange = NSRange(location: fullRange.location + offset, length: fullRange.length)
                if let swiftRange = Range(nsRange, in: result) {
                    result.replaceSubrange(swiftRange, with: replacement)
                    offset += replacement.count - fullRange.length
                }
            }
        }

        return result
    }

    private func cleanString(_ input: String) -> String {
        let noSlashes = input.replacingOccurrences(of: "/", with: "")
        let singleSpaced = noSlashes.replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)

        // Replace multiple commas with a single comma
        let singleComma = singleSpaced.replacingOccurrences(of: ",+", with: ",", options: .regularExpression)

        return singleComma
    }
}
