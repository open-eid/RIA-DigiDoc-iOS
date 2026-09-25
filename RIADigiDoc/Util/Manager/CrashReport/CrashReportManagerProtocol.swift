// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

/// @mockable
@MainActor
protocol CrashReportManagerProtocol: Sendable {
    func evaluateCrashReporting() async
    func sendReport() async
    func alwaysSendReport() async
    func doNotSendReport() async
}
