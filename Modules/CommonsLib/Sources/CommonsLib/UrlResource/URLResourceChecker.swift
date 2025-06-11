import Foundation

public struct URLResourceChecker: URLResourceCheckerProtocol {
    public init() {}

    public func checkResourceIsReachable(_ url: URL) throws -> Bool {
        try url.checkResourceIsReachable()
    }
}
