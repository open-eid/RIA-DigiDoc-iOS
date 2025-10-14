import CommonsLib
import ConfigLib
import LibdigidocLibSwift
import LibdigidocLibObjC
import OSLog
import UniformTypeIdentifiers
import UtilsLib

@MainActor
class TimeStampSettingsViewModel: TimeStampSettingsViewModelProtocol, ObservableObject {
    private static let logger = Logger(
        subsystem: "ee.ria.digidoc.RIADigiDoc", category: "TimeStampServicesSettingsViewModel")

    // MARK: - Variables
    @Published var configuration: ConfigurationProvider?
    @Published var tsaUrl: String = ""
    @Published var selectedOption: ServicesSettingsOption = .defaultSetting
    @Published var tsaCertData: Data?
    @Published var isImportingTSACert: Bool = false
    @Published var isLoading: Bool = true

    // MARK: - Dependencies
    private let configurationRepository: ConfigurationRepositoryProtocol
    private let dataStore: DataStoreProtocol
    private let fileManager: FileManagerProtocol
    private let advancedSettingsRepository: AdvancedSettingsRepositoryProtocol
    private let certificateUtil: CertificateUtilProtocol

    private var configurationObservationTask: Task<Void, Never>?

    // MARK: - Init

    init(
        configurationRepository: ConfigurationRepositoryProtocol,
        dataStore: DataStoreProtocol,
        fileManager: FileManagerProtocol,
        advancedSettingsRepository: AdvancedSettingsRepositoryProtocol,
        certificateUtil: CertificateUtilProtocol
    ) {
        self.configurationRepository = configurationRepository
        self.dataStore = dataStore
        self.fileManager = fileManager
        self.advancedSettingsRepository = advancedSettingsRepository
        self.certificateUtil = certificateUtil

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
        await loadTSACert()

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
        self.tsaUrl = await dataStore.getTSAUrl()

        if self.tsaUrl.isEmpty {
            self.tsaUrl = configuration?.tsaUrl.absoluteString ?? ""
        }

        self.selectedOption = await dataStore.getTSAUrlOption()
    }

    private func loadTSACert() async {
        tsaCertData = await advancedSettingsRepository.getCertificate(
            certificateFolder: CommonsLib.Constants.Folder.TSACert,
            certificateBaseName: CommonsLib.Constants.FileBaseName.TSACert,
        )
    }

    // MARK: - Setters

    public func saveSettings() async {
        await dataStore.setTSAUrlOption(selectedOption)
        tsaUrl = tsaUrl.trimmingCharacters(in: .whitespacesAndNewlines)

        if selectedOption == .defaultSetting || tsaUrl.isEmpty {
            tsaUrl = configuration?.tsaUrl.absoluteString ?? ""
        }

        await dataStore.setTSAUrl(tsaUrl: tsaUrl)
        await DigiDocConf.setTSUrl(tsaUrl)
    }

    // MARK: - TSA Cert Info Getters

    public func getTSACertIssuer() -> String {
        guard let cert = tsaCertData else { return "" }
        return certificateUtil.getSubjectAttribute(cert: cert, attribute: .RDNAttributeType.commonName)
    }

    public func getTSACertNotValidAfter(
        expiredLabel: String,
    ) -> String {
        guard let cert = tsaCertData else { return "" }
        return certificateUtil.getNotValidAfterWithExpiredLabel(
            cert: cert,
            expiredLabel: expiredLabel
        )
    }

    // MARK: - TSA Cert Import

    public func importTSACert(from url: URL) async {
        tsaCertData = await advancedSettingsRepository.importCertificate(
            from: url,
            certificateFolder: CommonsLib.Constants.Folder.TSACert,
            certificateBaseName: CommonsLib.Constants.FileBaseName.TSACert
        )
        if let tsaCertData = tsaCertData {
            await DigiDocConf.addTSCert(tsaCertData)
        }
    }

    // MARK: - Observer

    private func observeConfigurationUpdates() async {
        guard !Task.isCancelled else {
            return
        }

        guard let configStream = await configurationRepository.observeConfigurationUpdates() else {
            TimeStampSettingsViewModel.logger.error("Unable to get configuration updates stream")
            return
        }

        do {
            for try await config in configStream {
                await MainActor.run {
                    configuration = config
                }
            }
        } catch {
            TimeStampSettingsViewModel.logger.error("Unable to get configuration from stream")
        }
    }
}
