// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import FactoryKit

public struct LoggingSystem: Sendable {
    public static let configuration: LoggingConfiguration = LoggingConfiguration(
        isLoggingEnabled: Container.shared.isLoggingEnabled()
    )
}
