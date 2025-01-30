import Foundation
import Testing
@testable import UtilsLib

class DateUtilTests {

    @Test
    func getFormattedDateTime_successWithValidDateUTC() {
        let input = "1970-01-01T00:00:00Z"
        let isUTC = true
        let expectedOutput = "01.01.1970 00:00:00 +0000"

        let result = DateUtil.getFormattedDateTime(
            dateTimeString: input,
            isUTC: isUTC
        )

        #expect(expectedOutput == result)
    }

    @Test
    func getFormattedDateTime_successWithValidDateLocalTime() {
        let input = "1970-01-01T00:00:00Z"
        let isUTC = false

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss Z"
        dateFormatter.timeZone = TimeZone.current
        let expectedOutput = dateFormatter.string(from: Date(timeIntervalSince1970: 0))

        let result = DateUtil.getFormattedDateTime(
            dateTimeString: input,
            isUTC: isUTC
        )

        #expect(expectedOutput == result)
    }

    @Test
    func getFormattedDateTime_successWithCustomInputAndOutputFormats() {
        let input = "01/01/1970 00:00:00"
        let isUTC = true
        let inputFormat = "MM/dd/yyyy HH:mm:ss"
        let outputFormat = "yyyy/MM/dd HH:mm:ss Z"
        let expectedOutput = "1970/01/01 00:00:00 +0000"

        let result = DateUtil.getFormattedDateTime(
            dateTimeString: input,
            isUTC: isUTC,
            inputDateFormat: inputFormat,
            outputDateFormat: outputFormat
        )

        #expect(expectedOutput == result)
    }

    @Test
    func getFormattedDateTime_returnEmptyStringwithInvalidInputFormat() {
        let input = "01-01-1970 00:00:00"
        let isUTC = true

        let result = DateUtil.getFormattedDateTime(
            dateTimeString: input,
            isUTC: isUTC
        )

        #expect(input == result)
    }

    @Test
    func getFormattedDateTime_returnEmptyStringwithEmptyInput() {
        let input = ""
        let isUTC = true

        let result = DateUtil.getFormattedDateTime(
            dateTimeString: input,
            isUTC: isUTC
        )

        #expect(input == result)
    }

    @Test
    func getFormattedDateTime_returnEmptyStringwithInvalidDate() {
        let input = "InvalidDateFormat"
        let isUTC = true

        let result = DateUtil.getFormattedDateTime(
            dateTimeString: input,
            isUTC: isUTC
        )

        #expect(input == result)
    }
}
