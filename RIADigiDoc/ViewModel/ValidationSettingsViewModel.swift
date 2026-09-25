// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import CommonsLib
import ConfigLib
import LibdigidocLibSwift
import UniformTypeIdentifiers
import UtilsLib

@Observable
@MainActor
class ValidationSettingsViewModel: ValidationSettingsViewModelProtocol, Loggable {
    var configuration: ConfigurationProvider?
    var validationServiceUrl: String = ""
    var selectedOption: ServicesSettingsOption = .defaultSetting
    var sivaCertData: Data?
    var isImportingCert: Bool = false
    var isLoading: Bool = true

    // MARK: - Dependencies
    private let configurationRepository: ConfigurationRepositoryProtocol
    private let dataStore: DataStoreProtocol
    private let fileManager: FileManagerProtocol
    private let advancedSettingsRepository: AdvancedSettingsRepositoryProtocol
    private let certificateUtil: CertificateUtilProtocol

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

        Task {
            await initializeSettings()
        }
    }

    // MARK: - Init helpers

    public func initializeSettings() async {
        await configuration = configurationRepository.getConfiguration()
        await loadSettings()
        await loadSiVaCert()

        isLoading = false
    }

    private func loadSettings() async {
        self.validationServiceUrl = await dataStore.getValidationServiceURL()

        if self.validationServiceUrl.isEmpty {
            self.validationServiceUrl = configuration?.sivaUrl.absoluteString ?? ""
        }

        self.selectedOption = await dataStore.getValidationServiceOption()
    }

    private func loadSiVaCert() async {
        sivaCertData = await advancedSettingsRepository.getCertificate(
            certificateFolder: CommonsLib.Constants.Folder.SiVaCert,
            certificateBaseName: CommonsLib.Constants.FileBaseName.SiVaCert,
        )
    }

    // MARK: - Setters

    public func saveSettings() async {
        await dataStore.setValidationServiceOption(selectedOption)
        validationServiceUrl = validationServiceUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        var validationServiceURL: URL? = URL(string: validationServiceUrl)

        if selectedOption == .defaultSetting || validationServiceUrl.isEmpty {
            validationServiceUrl = configuration?.sivaUrl.absoluteString ?? ""
            validationServiceURL = configuration?.sivaUrl
        }

        await dataStore.setValidationServiceURL(validationServiceURL: validationServiceUrl)
        DigiDocConf.setSiVaInfo(
            url: validationServiceURL,
            cert: sivaCertData,
            option: selectedOption
        )
    }

    // MARK: - SiVa Cert Info Getters

    public func getSiVaCertIssuer() -> String {
        guard let cert = sivaCertData else { return "" }
        return certificateUtil.getSubjectAttribute(cert: cert, attribute: .RDNAttributeType.commonName)
    }

    public func getSiVaCertNotValidAfter(
        expiredLabel: String
    ) -> String {
        guard let cert = sivaCertData else { return "" }
        return certificateUtil.getNotValidAfterWithExpiredLabel(
            cert: cert,
            expiredLabel: expiredLabel
        )
    }

    // MARK: - SiVa Cert Import

    public func importSiVaCert(from url: URL) async {
        sivaCertData = await advancedSettingsRepository.importCertificate(
            from: url,
            certificateFolder: CommonsLib.Constants.Folder.SiVaCert,
            certificateBaseName: CommonsLib.Constants.FileBaseName.SiVaCert
        )
    }
}
