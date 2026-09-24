// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
