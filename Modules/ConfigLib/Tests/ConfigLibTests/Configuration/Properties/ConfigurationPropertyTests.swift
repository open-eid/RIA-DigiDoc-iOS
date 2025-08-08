import Foundation
import Testing
import UtilsLib
@testable import ConfigLib

class ConfigurationPropertyTests {

    @Test
    func fromProperties_returnConfigurationPropertyWithValidProperties() async throws {
        let validProperties: [String: String] = [
            "central-configuration-service.url": "https://someUrl.abc",
            "configuration.update-interval": "4",
            "configuration.version-serial": "123",
            "configuration.download-date": "1970-01-01 00:00:00"
        ]

        let configProperty = try ConfigurationProperty.fromProperties(properties: validProperties)
        let centralConfigurationServiceUrl = await configProperty.centralConfigurationServiceUrl
        let updateInterval = await configProperty.updateInterval
        let versionSerial = await configProperty.versionSerial
        let downloadDate = await configProperty.downloadDate

        #expect("https://someUrl.abc" == centralConfigurationServiceUrl)
        #expect(4 == updateInterval)
        #expect(123 == versionSerial)
        #expect(DateUtil.configurationDateFormatter.date(from: "1970-01-01 00:00:00") == downloadDate)
    }

    @Test
    func fromProperties_throwErrorWissingCentralConfigurationServiceUrl() async {
        let invalidProperties: [String: String] = [
            "configuration.update-interval": "5",
            "configuration.version-serial": "1234",
            "configuration.download-date": "1970-01-01 00:00:00"
        ]

        #expect(
            throws: ConfigurationPropertyError.missingOrInvalidProperty("central-configuration-service.url")
        ) {
            try ConfigurationProperty.fromProperties(properties: invalidProperties)
        }
    }

    @Test
    func fromProperties_throwErrorWhenInvalidUpdateInterval() async {
        let invalidProperties: [String: String] = [
            "central-configuration-service.url": "https://someUrl.abc",
            "configuration.update-interval": "notAnInt",
            "configuration.version-serial": "234",
            "configuration.download-date": "1970-01-01 00:00:00"
        ]

        #expect(
            throws: ConfigurationPropertyError.missingOrInvalidProperty("configuration.update-interval")
        ) {
            try ConfigurationProperty.fromProperties(properties: invalidProperties)
        }
    }

    @Test
    func fromProperties_throwerrorWhenInvalidVersionSerial() async {
        let invalidProperties: [String: String] = [
            "central-configuration-service.url": "https://someUrl.abc",
            "configuration.update-interval": "3",
            "configuration.version-serial": "test",
            "configuration.download-date": "1970-01-01 00:00:00"
        ]

        #expect(
            throws: ConfigurationPropertyError.missingOrInvalidProperty("configuration.version-serial")
        ) {
            try ConfigurationProperty.fromProperties(properties: invalidProperties)
        }
    }

    @Test
    func fromProperties_throwErrorWhenInvalidDownloadDate() async {
        let invalidProperties: [String: String] = [
            "central-configuration-service.url": "https://someUrl.abc",
            "configuration.update-interval": "3",
            "configuration.version-serial": "345",
            "configuration.download-date": "InvalidDate"
        ]

        #expect(
            throws: ConfigurationPropertyError.missingOrInvalidProperty("configuration.download-date")
        ) {
            try ConfigurationProperty.fromProperties(properties: invalidProperties)
        }
    }

    @Test
    func update_successUpdatingProperties() async {
        let initialDate = Date()
        let configProperty = ConfigurationProperty(
            centralConfigurationServiceUrl: "https://someUrl.abc",
            updateInterval: 5,
            versionSerial: 123,
            downloadDate: initialDate
        )
        let newUrl = "https://someUrl.abc"
        let newUpdateInterval = 4
        let newVersionSerial = 124
        let newDownloadDate = Date()

        await configProperty.update(
            centralConfigurationServiceUrl: newUrl,
            updateInterval: newUpdateInterval,
            versionSerial: newVersionSerial,
            downloadDate: newDownloadDate
        )

        let centralConfigurationServiceUrl = await configProperty.centralConfigurationServiceUrl
        let updateInterval = await configProperty.updateInterval
        let versionSerial = await configProperty.versionSerial
        let downloadDate = await configProperty.downloadDate

        #expect(newUrl == centralConfigurationServiceUrl)
        #expect(newUpdateInterval == updateInterval)
        #expect(newVersionSerial == versionSerial)
        #expect(newDownloadDate == downloadDate)
    }
}
