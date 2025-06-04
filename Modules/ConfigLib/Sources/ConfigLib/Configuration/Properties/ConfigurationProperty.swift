import Foundation
import UtilsLib

public actor ConfigurationProperty {

    var centralConfigurationServiceUrl: String
    var updateInterval: Int
    var versionSerial: Int
    var downloadDate: Date

    public init(centralConfigurationServiceUrl: String, updateInterval: Int, versionSerial: Int, downloadDate: Date) {
        self.centralConfigurationServiceUrl = centralConfigurationServiceUrl
        self.updateInterval = updateInterval
        self.versionSerial = versionSerial
        self.downloadDate = downloadDate
    }

    func update(
        centralConfigurationServiceUrl: String,
        updateInterval: Int,
        versionSerial: Int,
        downloadDate: Date
    ) async {
        self.centralConfigurationServiceUrl = centralConfigurationServiceUrl
        self.updateInterval = updateInterval
        self.versionSerial = versionSerial
        self.downloadDate = downloadDate
    }

    static func fromProperties(properties: [String: String]) throws -> ConfigurationProperty {
        guard let url = properties["central-configuration-service.url"] else {
            throw ConfigurationPropertyError.missingOrInvalidProperty("central-configuration-service.url")
        }

        guard let updateIntervalString = properties["configuration.update-interval"],
              let updateInterval = Int(updateIntervalString) else {
            throw ConfigurationPropertyError.missingOrInvalidProperty("configuration.update-interval")
        }

        guard let versionSerialString = properties["configuration.version-serial"],
              let versionSerial = Int(versionSerialString) else {
            throw ConfigurationPropertyError.missingOrInvalidProperty("configuration.version-serial")
        }

        guard let downloadDateString = properties["configuration.download-date"],
              let downloadDate = DateUtil.configurationDateFormatter.date(from: downloadDateString) else {
            throw ConfigurationPropertyError.missingOrInvalidProperty("configuration.download-date")
        }

        return ConfigurationProperty(centralConfigurationServiceUrl: url,
                                     updateInterval: updateInterval,
                                     versionSerial: versionSerial,
                                     downloadDate: downloadDate)
    }
}
