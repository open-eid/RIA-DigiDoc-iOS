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
@testable import ConfigLib

class DateExtensionTests {

    @Test
    func daysBetween_returnsCorrectDaysWhenFirstDateIsEarlier() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"

        guard let firstDate = dateFormatter.date(from: "1970/01/01"),
              let secondDate = dateFormatter.date(from: "1970/01/20") else {
            Issue.record("Failed to create dates")
            return
        }

        let daysBetween = firstDate.daysBetween(secondDate)

        #expect(daysBetween == 19)
    }

    @Test
    func daysBetween_returnsCorrectDaysWhenFirstDateIsLater() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"

        guard let firstDate = dateFormatter.date(from: "1970/01/20"),
              let secondDate = dateFormatter.date(from: "1970/01/01") else {
            Issue.record("Failed to create dates")
            return
        }

        let daysBetween = firstDate.daysBetween(secondDate)

        #expect(daysBetween == -19)
    }

    @Test
    func daysBetween_returnsZeroWhenDatesAreEqual() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"

        guard let firstDate = dateFormatter.date(from: "2025/01/01"),
              let secondDate = dateFormatter.date(from: "2025/01/01") else {
            Issue.record("Failed to create dates")
            return
        }

        let daysBetween = firstDate.daysBetween(secondDate)

        #expect(daysBetween == 0)
    }

    @Test
    func daysBetween_returnsCorrectDaysWhenSameTimesIncluded() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"

        guard let firstDate = dateFormatter.date(from: "1970/01/01 12:00"),
              let secondDate = dateFormatter.date(from: "1970/01/02 12:00") else {
            Issue.record("Failed to create dates")
            return
        }

        let daysBetween = firstDate.daysBetween(secondDate)

        #expect(daysBetween == 1)
    }

    @Test
    func daysBetween_returnsCorrectDaysDespiteTimesIncluded() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"

        guard let firstDate = dateFormatter.date(from: "1970/01/01 12:00"),
              let secondDate = dateFormatter.date(from: "1970/01/02 11:00") else {
            Issue.record("Failed to create dates")
            return
        }

        let daysBetween = firstDate.daysBetween(secondDate)

        #expect(daysBetween == 1)
    }
}
