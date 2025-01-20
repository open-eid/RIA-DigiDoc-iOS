import Foundation

enum ConfigurationCacheError: Error, Equatable {
    case fileNotFound
    case unableToCacheFile(String)
    case invalidData(String)
}
