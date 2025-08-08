import Foundation
import Testing
import UtilsLib
@testable import ConfigLib

final class DateUtilTests {

    @Test
    func dateFormatter_successWithCorrectDateFormat() {
        let expectedFormat = "dd-MM-yyyy HH:mm:ss"
        #expect(expectedFormat == DateUtil.dateFormatter.dateFormat)
    }

    @Test
    func dateFormatter_successParsingDate() {
        let dateString = "01-01-1970 00:00:00"
        let expectedDate = Calendar.current.date(
            from: DateComponents(
                year: 1970,
                month: 1,
                day: 01,
                hour: 00,
                minute: 00,
                second: 0
            )
        )

        let parsedDate = DateUtil.dateFormatter.date(from: dateString)
        #expect(expectedDate == parsedDate)
    }

    @Test
    func dateFormatter_successFormattingDate() {
        let dateFromComponents = Calendar.current.date(
            from: DateComponents(
                year: 1970,
                month: 1,
                day: 01,
                hour: 00,
                minute: 00,
                second: 0
            )
        )
        let expectedString = "01-01-1970 00:00:00"

        guard let date = dateFromComponents else {
            Issue.record("Unable to get date from components")
            return
        }

        let formattedString = DateUtil.dateFormatter.string(from: date)
        #expect(expectedString == formattedString)
    }

    @Test
    func configurationDateFormatter_successWithCorrectDateFormat() {
        let expectedFormat = "yyyy-MM-dd HH:mm:ss"
        #expect(expectedFormat == DateUtil.configurationDateFormatter.dateFormat)
    }

    @Test
    func configurationDateFormatter_successParsingDate() {
        let dateString = "1970-01-01 00:00:00"

        var calendar = Calendar(identifier: .gregorian)

        if let utcTimeZone = TimeZone(secondsFromGMT: 0) {
            calendar.timeZone = utcTimeZone

            let expectedDate = calendar.date(from: DateComponents(
                year: 1970,
                month: 1,
                day: 1,
                hour: 0,
                minute: 0,
                second: 0
            ))

            let parsedDate = DateUtil.configurationDateFormatter.date(from: dateString)
            #expect(expectedDate == parsedDate)
        } else {
            Issue.record("Unable to get UTC time zone")
            return
        }
    }

    @Test
    func configurationDateFormatter_successFormattingDate() {
        var calendar = Calendar(identifier: .gregorian)

        if let utcTimeZone = TimeZone(secondsFromGMT: 0) {
            calendar.timeZone = utcTimeZone

            let expectedDate = calendar.date(from: DateComponents(
                year: 1970,
                month: 1,
                day: 1,
                hour: 0,
                minute: 0,
                second: 0
            ))

            let expectedString = "1970-01-01 00:00:00"

            guard let date = expectedDate else {
                Issue.record("Unable to get date from components")
                return
            }

            let formattedString = DateUtil.configurationDateFormatter.string(from: date)
            #expect(expectedString == formattedString)
        } else {
            Issue.record("Unable to get UTC time zone")
            return
        }
    }

    @Test
    func dateFormatter_returnNilParsingInvalidDateString() {
        let invalidDateString = "invalid-date-format"
        let parsedDate = DateUtil.dateFormatter.date(from: invalidDateString)
        #expect(parsedDate == nil)
    }

    @Test
    func dateFormatter_returnNilParsingEmptyDateString() {
        let emptyDateString = ""
        let parsedDate = DateUtil.dateFormatter.date(from: emptyDateString)
        #expect(parsedDate == nil)
    }

    @Test
    func configurationDateFormatter_returnNilParsingInvalidDateString() {
        let invalidDateString = "31-01-1970 00:00:00"
        let parsedDate = DateUtil.configurationDateFormatter.date(from: invalidDateString)
        #expect(parsedDate == nil)
    }

    @Test
    func configurationDateFormatter_returnNilParsingEmptyDateString() {
        let emptyDateString = ""
        let parsedDate = DateUtil.configurationDateFormatter.date(from: emptyDateString)
        #expect(parsedDate == nil)
    }

    @Test
    func dateFormatter_successHandlingLeapYearDate() {
        let leapYearDateString = "29-02-1972 00:00:00"
        let expectedDate = Calendar.current.date(
            from: DateComponents(
                year: 1972,
                month: 2,
                day: 29,
                hour: 00,
                minute: 0,
                second: 0
            )
        )
        let parsedDate = DateUtil.dateFormatter.date(from: leapYearDateString)
        #expect(expectedDate == parsedDate)
    }

    @Test
    func configurationDateFormatter_successHandlingLeapYearDate() {
        var calendar = Calendar(identifier: .gregorian)

        if let utcTimeZone = TimeZone(secondsFromGMT: 0) {
            calendar.timeZone = utcTimeZone

            let expectedDate = calendar.date(from: DateComponents(
                year: 1972,
                month: 2,
                day: 29,
                hour: 00,
                minute: 0,
                second: 0
            ))

            let leapYearDateString = "1972-02-29 00:00:00"

            let parsedDate = DateUtil.configurationDateFormatter.date(from: leapYearDateString)
            #expect(expectedDate == parsedDate)
        } else {
            Issue.record("Unable to get UTC time zone")
            return
        }
    }

    @Test
    func dateFormatter_returnNilWhenHandlingNonLeapYearFebruary29() {
        let invalidDateString = "29-02-1970 00:00:00"
        let parsedDate = DateUtil.dateFormatter.date(from: invalidDateString)
        #expect(parsedDate == nil)
    }

    @Test
    func configurationDateFormatter_returnNilWhenHandlingNonLeapYearFebruary29() {
        let invalidDateString = "1970-02-29 00:00:00"
        let parsedDate = DateUtil.configurationDateFormatter.date(from: invalidDateString)
        #expect(parsedDate == nil)
    }
}
