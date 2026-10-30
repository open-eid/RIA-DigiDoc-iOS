// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import ConfigLib
import UtilsLib

public struct AppVersionUtil: AppVersionUtilProtocol, Loggable {

    let configurationLoader: ConfigurationLoaderProtocol

    public func isAppVersionUnsupported() async -> Bool {
        let appVersion = BundleUtil.getAppVersion()
        let isUnsupported = await configurationLoader.getConfiguration()?
            .isAppVersionUnsupported(appVersion) == true

        if isUnsupported {
            AppVersionUtil.logger().error("App version \(appVersion, privacy: .public) is unsupported")
        }

        return isUnsupported
    }
}
