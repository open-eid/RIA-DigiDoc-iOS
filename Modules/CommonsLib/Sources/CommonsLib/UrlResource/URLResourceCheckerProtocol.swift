import Foundation

/// @mockable
public protocol URLResourceCheckerProtocol {
    func checkResourceIsReachable(_ url: URL) throws -> Bool
}
