// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

/// @mockable
@MainActor
protocol CrashReportClientProtocol: Sendable {
    func checkForUnsentReports() async -> Bool
    func sendUnsentReports()
    func deleteUnsentReports()
}
