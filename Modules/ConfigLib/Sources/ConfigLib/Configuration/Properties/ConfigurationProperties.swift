import Foundation
import CommonsLib
import UtilsLib

public actor ConfigurationProperties: ConfigurationPropertiesProtocol {

    private let userDefaults: UserDefaults

    public init(suiteName: String? = nil) {
        if let suiteName = suiteName {
            self.userDefaults = UserDefaults(suiteName: suiteName) ?? .standard
        } else {
            self.userDefaults = .standard
        }
    }

    public func getConfigurationProperties(from propertiesFile: URL) async throws -> ConfigurationProperty {
        guard let properties = loadProperties(from: propertiesFile) else {
            throw ConfigurationPropertyError
            .noSuchFile(
                "\(Constants.Configuration.DefaultConfigurationPropertiesFileName).properties"
            )
        }
        return try ConfigurationProperty.fromProperties(properties: properties)
    }

    public func updateProperties(lastUpdateCheck: Date?, lastUpdated: Date?, serial: Int?) async {
        await setConfigurationLastCheckDate(date: lastUpdateCheck)
        await setConfigurationUpdatedDate(date: lastUpdated)
        await setConfigurationVersionSerial(serial: serial)
    }

    public func setConfigurationUpdatedDate(date: Date?) async {
        if let date = date {
            let dateString = DateUtil.configurationDateFormatter.string(from: date)
            userDefaults.set(dateString, forKey: CommonsLib.Constants.Configuration.UpdateDatePropertyName)
        }
    }

    public func getConfigurationUpdatedDate() async -> Date? {
        if let dateString = userDefaults.string(forKey: CommonsLib.Constants.Configuration.UpdateDatePropertyName) {
            return DateUtil.configurationDateFormatter.date(from: dateString)
        }
        return nil
    }

    public func setConfigurationLastCheckDate(date: Date?) async {
        if let date = date {
            let dateString = DateUtil.configurationDateFormatter.string(from: date)
            userDefaults.set(
                dateString,
                forKey: CommonsLib.Constants.Configuration.LastUpdateCheckDatePropertyName
            )
        }
    }

    public func getConfigurationLastCheckDate() async -> Date? {
        if let dateString = userDefaults.string(
            forKey: CommonsLib.Constants.Configuration.LastUpdateCheckDatePropertyName
        ) {
            return DateUtil.configurationDateFormatter.date(from: dateString)
        }
        return nil
    }

    public func setConfigurationVersionSerial(serial: Int?) async {
        if let serial = serial {
            userDefaults.set(serial, forKey: CommonsLib.Constants.Configuration.VersionSerialPropertyName)
        }
    }

    public func getConfigurationVersionSerial() async -> Int? {
        return userDefaults.integer(forKey: CommonsLib.Constants.Configuration.VersionSerialPropertyName)
    }

    private func loadProperties(from propertiesFile: URL) -> [String: String]? {
        guard let fileContents = try? String(contentsOfFile: propertiesFile.path) else {
            return nil
        }

        var properties = [String: String]()
        fileContents.enumerateLines { (line, _) in
            let components = line.split(separator: "=").map { String($0) }
            if components.count == 2 {
                properties[components[0]] = components[1]
            }
        }
        return properties
    }
}
