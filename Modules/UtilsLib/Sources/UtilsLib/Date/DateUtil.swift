import Foundation

public class DateUtil {
    public static func getFormattedDateTime(
        dateTimeString: String,
        isUTC: Bool,
        inputDateFormat: String = "yyyy-MM-dd'T'HH:mm:ss'Z'",
        outputDateFormat: String = "dd.MM.yyyy HH:mm:ss Z"
    ) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = inputDateFormat
        inputFormatter.locale = Locale.current
        inputFormatter.timeZone = TimeZone(abbreviation: "UTC")

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = outputDateFormat
        outputFormatter.locale = Locale.current
        outputFormatter.timeZone = isUTC ? TimeZone(abbreviation: "UTC") : TimeZone.current

        if let date = inputFormatter.date(from: dateTimeString) {
            return outputFormatter.string(from: date)
        }
        return dateTimeString
    }
}
