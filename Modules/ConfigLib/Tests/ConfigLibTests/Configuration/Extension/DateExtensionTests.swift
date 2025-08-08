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
