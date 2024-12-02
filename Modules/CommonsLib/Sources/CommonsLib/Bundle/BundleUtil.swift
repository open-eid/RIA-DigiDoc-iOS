import Foundation
import OSLog
import ZIPFoundation

public class BundleUtil {

    private static let logger = Logger(subsystem: "ee.ria.digidoc.CommonsLib", category: "BundleUtil")

    public init() {}

    public static func getBundleIdentifier() -> String {
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "ee.ria.digidoc"
        logger.debug("Using bundle identifier: \(bundleIdentifier)")
        return bundleIdentifier
    }
}
