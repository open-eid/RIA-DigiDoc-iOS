import Foundation
import OSLog

public struct SystemUtil {

    private static let logger = Logger(subsystem: "ee.ria.digidoc.CommonsLib", category: "SystemUtil")

    public static func getOSVersion() -> String {
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        let versionString = "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
        logger.debug("Operating system version: \(versionString)")
        return versionString
    }
}
