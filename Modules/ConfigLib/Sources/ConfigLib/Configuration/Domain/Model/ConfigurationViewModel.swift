import Foundation
import OSLog
import UtilsLib
import CommonsLib

@MainActor
class ConfigurationViewModel {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "ConfigurationViewModel")

    private(set) var configuration: ConfigurationProvider?

    private let repository: ConfigurationRepositoryProtocol
    private let fileManager: FileManagerProtocol

    init(
        repository: ConfigurationRepositoryProtocol,
        fileManager: FileManagerProtocol
    ) {
        self.repository = repository
        self.fileManager = fileManager
    }

    func fetchConfiguration(lastUpdate: TimeInterval) async {
        do {
            guard let updates = try await repository.getCentralConfigurationUpdates(
                cacheDir: Directories.getConfigDirectory(fileManager: fileManager)
            ) else {
                ConfigurationViewModel.logger.error("No configuration updates available.")
                return
            }

            for try await config in updates {
                if let configurationProvider = config {
                    let confUpdateDate = configurationProvider.configurationUpdateDate
                    if lastUpdate == 0 || (confUpdateDate?.timeIntervalSince1970 ?? 0) > lastUpdate {
                        self.configuration = configurationProvider
                    }
                }
            }
        } catch {
            ConfigurationViewModel.logger.error("Unable to fetch configuration: \(error.localizedDescription)")
        }
    }

    func getConfiguration() async -> ConfigurationProvider? {
        do {
            guard let updates = await repository.getConfigurationUpdates() else {
                ConfigurationViewModel.logger.error("Configuration updates provider is nil")
                return nil
            }

            for try await config in updates {
                if let configurationProvider = config {
                    return configurationProvider
                }
            }
        } catch {
            ConfigurationViewModel.logger.error("Unable to get configuration: \(error.localizedDescription)")
            return nil
        }
        return nil
    }
}
