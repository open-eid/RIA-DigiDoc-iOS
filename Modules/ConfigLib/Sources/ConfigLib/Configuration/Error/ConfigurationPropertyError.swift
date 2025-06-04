import Foundation

enum ConfigurationPropertyError: Error, Equatable {
    case missingOrInvalidProperty(String)
    case noSuchFile(String)

    var errorDescription: String? {
        switch self {
        case .missingOrInvalidProperty(let key):
            return "Missing or invalid property: \(key)"
        case .noSuchFile(let path):
            return "No such configuration file: \(path)"
        }
    }

    var description: String {
        return errorDescription ?? "ConfigurationPropertyError"
    }
}
