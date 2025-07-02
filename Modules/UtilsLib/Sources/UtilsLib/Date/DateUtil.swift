import Foundation

public class DateUtil {
    public static func getFormattedDateTime(
        dateTimeString: String,
        isUTC: Bool,
        inputDateFormat: String = "yyyy-MM-dd'T'HH:mm:ss'Z'",
        dateOutputFormat: String = "dd.MM.yyyy",
        timeOutputFormat: String = "HH:mm:ss"
    ) -> (date: String, time: String) {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = inputDateFormat
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.timeZone = TimeZone(abbreviation: "UTC")

        let outputDateFormatter = DateFormatter()
        outputDateFormatter.dateFormat = dateOutputFormat
        outputDateFormatter.locale = Locale.current
        outputDateFormatter.timeZone = isUTC ? TimeZone(abbreviation: "UTC") : TimeZone.current

        let outputTimeFormatter = DateFormatter()
        outputTimeFormatter.dateFormat = timeOutputFormat
        outputTimeFormatter.locale = Locale.current
        outputTimeFormatter.timeZone = isUTC ? TimeZone(abbreviation: "UTC") : TimeZone.current

        guard let date = inputFormatter.date(from: dateTimeString) else {
            return ("", "")
        }

        let datePart = outputDateFormatter.string(from: date)
        let timePart = outputTimeFormatter.string(from: date)

        return (datePart, timePart)
    }

    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        return formatter
    }()

    public static let configurationDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
}
