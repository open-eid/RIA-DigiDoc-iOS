import Foundation
import OSLog

public struct BundleUtil {

    private static let logger = Logger(subsystem: "ee.ria.digidoc.CommonsLib", category: "BundleUtil")

    public static func getBundleIdentifier() -> String {
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "ee.ria.digidoc"
        logger.debug("Using bundle identifier: \(bundleIdentifier)")
        return bundleIdentifier
    }
    
    public static func getBundleShortVersionString(bundle: Bundle = Bundle.main) -> String {
        let versionString = bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "3.0.0"
        logger.debug("Bundle short version string from info.plist: \(versionString)")
        return versionString
    }
    
    public static func getBundleVersion(bundle: Bundle = Bundle.main) -> String {
        let appVersion = bundle.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        logger.debug("Bundle version from info.plist: \(appVersion)")
        return appVersion
    }
}
