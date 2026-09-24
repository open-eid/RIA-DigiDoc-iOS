// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public class DateUtil {
    public static func getFormattedDateTime(
        dateTimeString: String,
        isUTC: Bool,
        inputDateFormat: String = "yyyy-MM-dd'T'HH:mm:ss'Z'",
        dateOutputFormat: String = "dd.MM.yyyy",
        timeOutputFormat: String = "HH:mm:ss"
    ) -> (date: String, time: String) {
        let inputFormatter = outputDateFormatter(format: inputDateFormat, isUTC: true)
        guard let date = inputFormatter.date(from: dateTimeString) else {
            return ("", "")
        }

        return getFormattedDateTime(
            date: date,
            isUTC: isUTC,
            dateOutputFormat: dateOutputFormat,
            timeOutputFormat: timeOutputFormat
        )
    }

    public static func getFormattedDateTime(
        date: Date,
        isUTC: Bool,
        dateOutputFormat: String = "dd.MM.yyyy",
        timeOutputFormat: String = "HH:mm:ss"
    ) -> (date: String, time: String) {

        let dateFormatter = outputDateFormatter(format: dateOutputFormat, isUTC: isUTC)
        let timeFormatter = outputDateFormatter(format: timeOutputFormat, isUTC: isUTC)

        return (
            dateFormatter.string(from: date),
            timeFormatter.string(from: date)
        )
    }

    public static func stringToDate(
        _ dateString: String,
        isUTC: Bool,
        dateOutputFormat: String = "dd.MM.yyyy"
    ) -> Date? {
        let formatter = outputDateFormatter(
            format: dateOutputFormat,
            isUTC: isUTC
        )

        return formatter.date(from: dateString)
    }

    private static func outputDateFormatter(
        format: String,
        isUTC: Bool = false
    ) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = isUTC
        ? TimeZone(abbreviation: "UTC")
        : TimeZone.current
        return formatter
    }

    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        return formatter
    }()

    public static let configurationDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }()
}
