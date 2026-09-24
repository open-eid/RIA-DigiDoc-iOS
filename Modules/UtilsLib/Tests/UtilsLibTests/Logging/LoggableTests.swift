// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Testing
import UtilsLib
import UtilsLibMocks

struct LoggableTests {
    @Test
    func logger_createsLoggerWithCorrectCategory() {
        let expectedCategory = "LoggableMock"
        let category = LoggableMock.category
        #expect(category == expectedCategory)
    }
}
