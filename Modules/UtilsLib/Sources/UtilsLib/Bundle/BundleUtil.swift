// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public struct BundleUtil: Loggable {
    public static func getBundleIdentifier() -> String {
        return Bundle.main.bundleIdentifier ?? "ee.ria.digidoc"
    }

    public static func getBundleShortVersionString(bundle: Bundle = Bundle.main) -> String {
        return bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
    }

    public static func getBundleVersion(bundle: Bundle = Bundle.main) -> String {
        return bundle.infoDictionary?["CFBundleVersion"] as? String ?? "-"
    }

    public static func getAppVersion(bundle: Bundle = Bundle.main) -> String {
        return "\(getBundleShortVersionString(bundle: bundle)).\(getBundleVersion(bundle: bundle))"
    }
}
