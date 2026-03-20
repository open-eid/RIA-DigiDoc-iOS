/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
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
