import Foundation
import OSLog

public struct BundleUtil {

    private static let logger = Logger(subsystem: "ee.ria.digidoc.CommonsLib", category: "BundleUtil")

    public static func getBundleIdentifier() -> String {
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "ee.ria.digidoc"
        logger.debug("Using bundle identifier: \(bundleIdentifier)")
        return bundleIdentifier
    }
}
