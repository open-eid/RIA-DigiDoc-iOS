import Foundation
import Testing
@testable import UtilsLib

class DateUtilTests {

    @Test
    func getFormattedDateTime_successWithValidDateUTC() {
        let input = "1970-01-01T00:00:00Z"
        let isUTC = true
        let expectedDate = "01.01.1970"
        let expectedTime = "00:00:00"

        let result = DateUtil.getFormattedDateTime(
            dateTimeString: input,
            isUTC: isUTC
        )

        #expect(expectedDate == result.date)
        #expect(expectedTime == result.time)
    }

    @Test
    func getFormattedDateTime_successWithValidDateLocalTime() {
        let input = "1970-01-01T00:00:00Z"
        let isUTC = false

        let date = Date(timeIntervalSince1970: 0)

        let expectedDateFormatter = DateFormatter()
        expectedDateFormatter.dateFormat = "dd.MM.yyyy"
        expectedDateFormatter.timeZone = TimeZone.current
        expectedDateFormatter.locale = Locale.current
        let expectedDate = expectedDateFormatter.string(from: date)

        let expectedTimeFormatter = DateFormatter()
        expectedTimeFormatter.dateFormat = "HH:mm:ss"
        expectedTimeFormatter.timeZone = TimeZone.current
        expectedTimeFormatter.locale = Locale.current
        let expectedTime = expectedTimeFormatter.string(from: date)

        let result = DateUtil.getFormattedDateTime(
            dateTimeString: input,
            isUTC: isUTC
        )

        #expect(expectedDate == result.date)
        #expect(expectedTime == result.time)
    }

    @Test
    func getFormattedDateTime_successWithCustomInputAndOutputFormats() {
        let input = "01/01/1970 00:00:00"
        let isUTC = true
        let inputFormat = "MM/dd/yyyy HH:mm:ss"
        let outputDateFormat = "yyyy/MM/dd"
        let outputTimeFormat = "HH:mm:ss Z"

        let expectedDateFormatter = DateFormatter()
        expectedDateFormatter.dateFormat = outputDateFormat
        expectedDateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        expectedDateFormatter.locale = Locale.current

        let expectedTimeFormatter = DateFormatter()
        expectedTimeFormatter.dateFormat = outputTimeFormat
        expectedTimeFormatter.timeZone = TimeZone(abbreviation: "UTC")
        expectedTimeFormatter.locale = Locale.current

        let expectedDate = expectedDateFormatter.string(from: Date(timeIntervalSince1970: 0))
        let expectedTime = expectedTimeFormatter.string(from: Date(timeIntervalSince1970: 0))

        let result = DateUtil.getFormattedDateTime(
            dateTimeString: input,
            isUTC: isUTC,
            inputDateFormat: inputFormat,
            dateOutputFormat: outputDateFormat,
            timeOutputFormat: outputTimeFormat
        )

        #expect(expectedDate == result.date)
        #expect(expectedTime == result.time)
    }

    @Test
    func getFormattedDateTime_returnEmptyTupleWithInvalidInputFormat() {
        let input = "01-01-1970 00:00:00"
        let isUTC = true

        let result = DateUtil.getFormattedDateTime(
            dateTimeString: input,
            isUTC: isUTC
        )

        #expect(result == ("", ""))
    }

    @Test
    func getFormattedDateTime_returnEmptyStringwithEmptyInput() {
        let input = ""
        let isUTC = true

        let result = DateUtil.getFormattedDateTime(
            dateTimeString: input,
            isUTC: isUTC
        )

        #expect(result.date == "")
        #expect(result.time == "")
    }

    @Test
    func getFormattedDateTime_returnEmptyStringwithInvalidDate() {
        let input = "InvalidDateFormat"
        let isUTC = true

        let result = DateUtil.getFormattedDateTime(
            dateTimeString: input,
            isUTC: isUTC
        )

        #expect(result == ("", ""))
    }
}
