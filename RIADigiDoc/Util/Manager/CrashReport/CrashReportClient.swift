// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import FirebaseCrashlytics

@MainActor
@Observable
final class CrashReportClient: CrashReportClientProtocol {
    func checkForUnsentReports() async -> Bool {
        await Crashlytics.crashlytics().checkForUnsentReports()
    }

    func sendUnsentReports() {
        Crashlytics.crashlytics().sendUnsentReports()
    }

    func deleteUnsentReports() {
        Crashlytics.crashlytics().deleteUnsentReports()
    }
}
