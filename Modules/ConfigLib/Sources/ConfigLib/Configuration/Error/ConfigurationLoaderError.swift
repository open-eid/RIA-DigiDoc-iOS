import Foundation

enum ConfigurationLoaderError: Error {
    case configurationNotFound
    case publicKeyNotFound
    case signatureNotFound
    case configurationVerificationFailed
    case configurationLoadFailed
}
