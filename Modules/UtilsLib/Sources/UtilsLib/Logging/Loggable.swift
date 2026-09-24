// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import OSLog

/// @mockable
public protocol Loggable: Sendable {}

public extension Loggable {
    static func logger(file: String = #fileID) -> Logger {
        guard LoggingSystem.configuration.isLoggingEnabled else {
            return Logger(.disabled)
        }

        let filePath = String(file)
        let moduleName = URL(fileURLWithPath: filePath)
            .lastPathComponent
            .split(separator: ".")
            .first
            .map(String.init) ?? "UnknownModule"

        let subsystem = "\(BundleUtil.getBundleIdentifier()).\(moduleName)"

        return Logger(subsystem: subsystem, category: category)
    }

    static var category: String {
        String(describing: Self.self)
    }
}
