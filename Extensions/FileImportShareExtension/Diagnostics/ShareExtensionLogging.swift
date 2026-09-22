// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import os

enum ShareExtensionLogging {
    static let subsystem = "ee.ria.digidoc.shareext.logging"
    static let category = "import"

    private static let log = Logger(subsystem: subsystem, category: category)

    static func info(_ message: String) {
        log.info("\(message, privacy: .public)")
    }

    static func error(_ message: String) {
        log.error("\(message, privacy: .public)")
    }
}
