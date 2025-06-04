import Foundation

/// @mockable
public protocol ConfigurationPropertiesProtocol: Sendable {
    func getConfigurationProperties(from propertiesFile: URL) async throws -> ConfigurationProperty
    func updateProperties(lastUpdateCheck: Date?, lastUpdated: Date?, serial: Int?) async
    func getConfigurationUpdatedDate() async -> Date?
    func setConfigurationUpdatedDate(date: Date?) async
    func getConfigurationLastCheckDate() async -> Date?
    func setConfigurationLastCheckDate(date: Date?) async
    func getConfigurationVersionSerial() async -> Int?
    func setConfigurationVersionSerial(serial: Int?) async
}
