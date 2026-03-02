/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

import Foundation
import Testing

@MainActor
struct CrashReportManagerTests {

    private let mockDataStore: DataStoreProtocolMock
    private let mockCrashClient: CrashReportClientProtocolMock
    private let crashManager: CrashReportManager

    init() async throws {
        mockDataStore = DataStoreProtocolMock()
        mockCrashClient = CrashReportClientProtocolMock()
        crashManager = CrashReportManager(
            dataStore: mockDataStore,
            crashReportClient: mockCrashClient
        )
    }

    @Test
    func evaluateCrashReporting_hideDialogWhenNoUnsentReports() async throws {
        mockDataStore.getIsCrashlyticsAlwaysEnabledHandler = { true }
        mockCrashClient.checkForUnsentReportsHandler = { false }

        await crashManager.evaluateCrashReporting()

        #expect(!crashManager.showCrashDialog)
    }

    @Test
    func evaluateCrashReporting_showDialogWhenAlwaysSendingUnsentReportsNotEnabled() async throws {
        mockDataStore.getIsCrashlyticsAlwaysEnabledHandler = { false }
        mockCrashClient.checkForUnsentReportsHandler = { true }

        await crashManager.evaluateCrashReporting()

        #expect(crashManager.showCrashDialog)
        #expect(mockCrashClient.sendUnsentReportsCallCount == 0)
        #expect(mockCrashClient.deleteUnsentReportsCallCount == 0)
    }

    @Test
    func evaluateCrashReporting_sendReportsUnsentReportsAlwaysEnabled() async throws {
        mockDataStore.getIsCrashlyticsAlwaysEnabledHandler = { true }
        mockCrashClient.checkForUnsentReportsHandler = { true }

        await crashManager.evaluateCrashReporting()

        #expect(!crashManager.showCrashDialog)
        #expect(mockCrashClient.sendUnsentReportsCallCount == 1)
        #expect(mockCrashClient.deleteUnsentReportsCallCount == 0)
    }

    @Test
    func sendReport_sendReportsAndHideDialog() async throws {
        mockCrashClient.checkForUnsentReportsHandler = { true }

        await crashManager.sendReport()

        #expect(!crashManager.showCrashDialog)
        #expect(mockCrashClient.sendUnsentReportsCallCount == 1)
        #expect(mockCrashClient.deleteUnsentReportsCallCount == 0)
    }

    @Test
    func alwaysSendReport_sendReportsAndHideDialogWhenReportsSendingAlwaysEnabled() async throws {
        mockCrashClient.checkForUnsentReportsHandler = { true }

        await crashManager.alwaysSendReport()

        #expect(!crashManager.showCrashDialog)
        #expect(mockDataStore.setIsCrashlyticsAlwaysEnabledCallCount == 1)
        #expect(mockCrashClient.sendUnsentReportsCallCount == 1)
        #expect(mockCrashClient.deleteUnsentReportsCallCount == 0)
    }

    @Test
    func doNotSendReport_deleteReportsAndHideDialog() async throws {
        mockCrashClient.checkForUnsentReportsHandler = { true }

        await crashManager.doNotSendReport()

        #expect(!crashManager.showCrashDialog)
        #expect(mockCrashClient.sendUnsentReportsCallCount == 0)
        #expect(mockCrashClient.deleteUnsentReportsCallCount == 1)
    }
}
