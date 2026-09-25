// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

/// @mockable
public protocol UserAgentUtilProtocol: Sendable {
    func userAgent(
        diagnostics: UserAgentDiagnostics,
        language: String
    ) -> String

    func appInfo(
        diagnostics: UserAgentDiagnostics,
        language: String
    ) -> String
}
