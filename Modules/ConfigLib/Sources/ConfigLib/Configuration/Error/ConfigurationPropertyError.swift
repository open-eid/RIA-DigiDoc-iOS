import Foundation

enum ConfigurationPropertyError: Error, Equatable {
    case missingOrInvalidProperty(String)
    case noSuchFile(String)
}
