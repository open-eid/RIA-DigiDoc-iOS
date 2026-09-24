// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public struct SystemUtil: Loggable {
    public static var isSimulator: Bool {
        #if targetEnvironment(simulator)
            logger().info("App is running on a simulator")
            return true
        #else
            return false
        #endif
    }

    public static func getOSVersion() -> String {
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        let versionString = "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
        logger().info("Operating system version: \(versionString, privacy: .public)")
        return versionString
    }

    public static func getDeviceModelIdentifier() -> String {
        if let simulatorModel = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] {
            return simulatorModel.lowercased()
        }

        var systemInfo = utsname()
        uname(&systemInfo)
        let identifier = withUnsafeBytes(of: &systemInfo.machine) { raw in
            String(bytes: raw.prefix { $0 != 0 }, encoding: .utf8) ?? ""
        }
        return identifier.lowercased()
    }
}
