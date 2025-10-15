import CommonsLib
import ConfigLib
import LibdigidocLibSwift
import OSLog
import UniformTypeIdentifiers
import UtilsLib

@MainActor
class ValidationSettingsViewModel: ValidationSettingsViewModelProtocol, ObservableObject {
    private static let logger = Logger(
        subsystem: "ee.ria.digidoc.RIADigiDoc", category: "ValidationSettingsViewModel")

    @Published var configuration: ConfigurationProvider?
    @Published var validationServiceURL: String = ""
    @Published var selectedOption: ServicesSettingsOption = .defaultSetting
    @Published var sivaCertData: Data?
    @Published var isImportingCert: Bool = false
    @Published var isLoading: Bool = true

    // MARK: - Dependencies
    private let configurationRepository: ConfigurationRepositoryProtocol
    private let dataStore: DataStoreProtocol
    private let fileManager: FileManagerProtocol
    private let advancedSettingsRepository: AdvancedSettingsRepositoryProtocol

    private var configurationObservationTask: Task<Void, Never>?

    init(
        configurationRepository: ConfigurationRepositoryProtocol,
        dataStore: DataStoreProtocol,
        fileManager: FileManagerProtocol,
        advancedSettingsRepository: AdvancedSettingsRepositoryProtocol
    ) {
        self.configurationRepository = configurationRepository
        self.dataStore = dataStore
        self.fileManager = fileManager
        self.advancedSettingsRepository = advancedSettingsRepository

        configurationObservationTask = Task {
            await observeConfigurationUpdates()
        }

        Task {
            await initializeSettings()
        }
    }

    public func removeObservers() async {
        configurationObservationTask?.cancel()
    }

    // MARK: - Init helpers

    private func initializeSettings() async {
        await ensureConfigurationLoaded()
        await loadSettings()
        await loadSiVaCert()

        isLoading = false
    }

    private func ensureConfigurationLoaded() async {
        if configuration == nil {
            for await config in $configuration.values where config != nil {
                break
            }
        }
    }

    private func loadSettings() async {
        self.validationServiceURL = await dataStore.getValidationServiceURL()

        if self.validationServiceURL.isEmpty {
            self.validationServiceURL = configuration?.sivaUrl.absoluteString ?? ""
        }

        self.selectedOption = await dataStore.getValidationServiceOption()
    }

    private func loadSiVaCert() async {
        sivaCertData = await advancedSettingsRepository.getCertificate(
            certificateFolder: CommonsLib.Constants.Folder.SivaCert,
            certificateBaseName: CommonsLib.Constants.FileBaseName.SiVaCert,
        )
    }

    // MARK: - Setters

    public func saveSettings() async {
        await dataStore.setValidationServiceOption(selectedOption)
        validationServiceURL = validationServiceURL.trimmingCharacters(in: .whitespacesAndNewlines)

        if selectedOption == .defaultSetting || validationServiceURL.isEmpty {
            validationServiceURL = configuration?.sivaUrl.absoluteString ?? ""
        }

        await dataStore.setValidationServiceURL(validationServiceURL: validationServiceURL)
        await DigiDocConf.setSiVaUrl(validationServiceURL)
    }

    // MARK: - SiVa Cert Info Getters

    public func getSiVaCertIssuer(testCert: Data? = nil) -> String {
        guard let cert = testCert ?? sivaCertData else { return "" }
        return CertificateUtil.getSubjectAttribute(cert: cert, attribute: .RDNAttributeType.commonName)
    }

    public func getSiVaCertNotValidAfter(
        expiredLabel: String,
        testCert: Data? = nil
    ) -> String {
        guard let cert = testCert ?? sivaCertData else { return "" }
        return CertificateUtil.getNotValidAfterWithExpiredLabel(
            cert: cert,
            expiredLabel: expiredLabel
        )
    }

    // MARK: - SiVa Cert Import

    public func importSiVaCert(from url: URL) async {
        sivaCertData = await advancedSettingsRepository.importCertificate(
            from: url,
            certificateFolder: CommonsLib.Constants.Folder.SivaCert,
            certificateBaseName: CommonsLib.Constants.FileBaseName.SiVaCert
        )
        if let sivaCertData = sivaCertData {
            await DigiDocConf.addSiVaCert(sivaCertData)
        }
    }

    // MARK: - Observer

    private func observeConfigurationUpdates() async {
        guard !Task.isCancelled else {
            return
        }

        guard let configStream = await configurationRepository.observeConfigurationUpdates() else {
            ValidationSettingsViewModel.logger.error("Unable to get configuration updates stream")
            return
        }

        do {
            for try await config in configStream {
                await MainActor.run {
                    configuration = config
                }
            }
        } catch {
            ValidationSettingsViewModel.logger.error("Unable to get configuration from stream")
        }
    }
}
