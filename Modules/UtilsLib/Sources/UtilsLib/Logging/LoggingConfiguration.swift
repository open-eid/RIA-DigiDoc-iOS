// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public struct LoggingConfiguration: Sendable {
    public let isLoggingEnabled: Bool

    public init(isLoggingEnabled: Bool) {
        self.isLoggingEnabled = isLoggingEnabled
    }
}
