/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

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

    public static func getAppVersion(bundle: Bundle = Bundle.main) -> String {
        return "\(getBundleShortVersionString(bundle: bundle)).\(getBundleVersion(bundle: bundle))"
    }
}
