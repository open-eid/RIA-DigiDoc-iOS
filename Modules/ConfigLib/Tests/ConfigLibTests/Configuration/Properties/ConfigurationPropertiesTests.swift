import Foundation
import Testing
@testable import ConfigLib

struct ConfigurationPropertiesTests {
    private let configurationProperties: ConfigurationProperties!
    private let testSuiteName = "ConfigurationPropertiesTests-\(UUID().uuidString)"

    init() async throws {
        UserDefaults().removePersistentDomain(forName: testSuiteName)

        configurationProperties = ConfigurationProperties(suiteName: testSuiteName)
    }

    @Test
    func loadProperties_returnPropertiesWhenFileExists() async throws {
        let mockPropertiesContent = """
        central-configuration-service.url=https://someurl.abc
        configuration.update-interval=4
        configuration.version-serial=123
        configuration.download-date=1970-01-01 00:00:00
        """
        let mockFile = createMockPropertiesFile(content: mockPropertiesContent)

        let properties = try await configurationProperties.getConfigurationProperties(from: mockFile)
        let configurationServiceUrl = await properties.centralConfigurationServiceUrl
        let versionSerial = await properties.versionSerial

        #expect("https://someurl.abc" == configurationServiceUrl)
        #expect(123 == versionSerial)
    }

    @Test
    func loadProperties_throwErrorWhenFileMissing() async {
        await #expect(throws: ConfigurationPropertyError.noSuchFile("config/configuration.properties")) {
            _ = try await configurationProperties.getConfigurationProperties(from: URL(fileURLWithPath: "notExist"))
        }
    }

    @Test
    func updateProperties_successUpdatingUserDefaults() async {
        var utcCalendar = Calendar(identifier: .gregorian)

        if let utcTimeZone = TimeZone(secondsFromGMT: 0) {
            utcCalendar.timeZone = utcTimeZone

            let lastUpdateCheck = utcCalendar.date(from: DateComponents(
                year: 1970,
                month: 1,
                day: 1,
                hour: 0,
                minute: 0,
                second: 0
            ))

            let lastUpdated = utcCalendar.date(from: DateComponents(
                year: 1970,
                month: 1,
                day: 1,
                hour: 0,
                minute: 0,
                second: 0
            ))

            let serial = 123

            await configurationProperties.updateProperties(
                lastUpdateCheck: lastUpdateCheck,
                lastUpdated: lastUpdated,
                serial: serial
            )

            let cachedLastUpdateCheck = await configurationProperties.getConfigurationLastCheckDate()
            let cachedLastUpdatedDate = await configurationProperties.getConfigurationUpdatedDate()
            let cachedSerial = await configurationProperties.getConfigurationVersionSerial()

            guard let cachedLastUpdate = cachedLastUpdateCheck, let cachedLastUpdated = cachedLastUpdatedDate else {
                Issue.record("Unable to get cached last update or last updated date")
                return
            }

            #expect(lastUpdateCheck == cachedLastUpdate)
            #expect(lastUpdated == cachedLastUpdated)
            #expect(serial == cachedSerial)
        } else {
            Issue.record("Unable to get UTC time zone")
            return
        }

    }

    @Test
    func getConfigurationUpdatedDate_successWhenSetConfigurationUpdatedDate() async {
        var utcCalendar = Calendar(identifier: .gregorian)

        if let utcTimeZone = TimeZone(secondsFromGMT: 0) {
            utcCalendar.timeZone = utcTimeZone

            let testDate = utcCalendar.date(from: DateComponents(
                year: 1970,
                month: 1,
                day: 1,
                hour: 0,
                minute: 0,
                second: 0
            ))

            await configurationProperties.setConfigurationUpdatedDate(date: testDate)
            let retrievedDate = await configurationProperties.getConfigurationUpdatedDate()

            #expect(testDate == retrievedDate)
        } else {
            Issue.record("Unable to get UTC time zone")
            return
        }
    }

    @Test
    func getConfigurationLastCheckDate_successWhenSetConfigurationLastCheckDate() async {
        var utcCalendar = Calendar(identifier: .gregorian)

        if let utcTimeZone = TimeZone(secondsFromGMT: 0) {
            utcCalendar.timeZone = utcTimeZone

            let testDate = utcCalendar.date(from: DateComponents(
                year: 1970,
                month: 1,
                day: 1,
                hour: 0,
                minute: 0,
                second: 0
            ))

            await configurationProperties.setConfigurationLastCheckDate(date: testDate)
            let retrievedDate = await configurationProperties.getConfigurationLastCheckDate()

            #expect(testDate == retrievedDate)
        } else {
            Issue.record("Unable to get UTC time zone")
            return
        }
    }

    @Test
    func getConfigurationVersionSerial_successWhenSetConfigurationConfigurationVersionSerial() async {
        let testSerial = 1234

        await configurationProperties.setConfigurationVersionSerial(serial: testSerial)
        let retrievedSerial = await configurationProperties.getConfigurationVersionSerial()

        #expect(testSerial == retrievedSerial)
    }

    private func createMockPropertiesFile(content: String) -> URL {
        let directory = FileManager.default.temporaryDirectory
        let filePath = directory.appendingPathComponent("default.properties")
        try? content.write(to: filePath, atomically: true, encoding: .utf8)
        return filePath
    }
}
