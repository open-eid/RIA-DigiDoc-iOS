/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

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
    @Published var validationServiceUrl: String = ""
    @Published var selectedOption: ServicesSettingsOption = .defaultSetting
    @Published var sivaCertData: Data?
    @Published var isImportingCert: Bool = false
    @Published var isLoading: Bool = true

    // MARK: - Dependencies
    private let configurationRepository: ConfigurationRepositoryProtocol
    private let dataStore: DataStoreProtocol
    private let fileManager: FileManagerProtocol
    private let advancedSettingsRepository: AdvancedSettingsRepositoryProtocol
    private let certificateUtil: CertificateUtilProtocol

    private var configurationObservationTask: Task<Void, Never>?

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

    public func initializeSettings() async {
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
        self.validationServiceUrl = await dataStore.getValidationServiceURL()

        if self.validationServiceUrl.isEmpty {
            self.validationServiceUrl = configuration?.sivaUrl.absoluteString ?? ""
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
        validationServiceUrl = validationServiceUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        var validationServiceURL: URL? = URL(string: validationServiceUrl)

        if selectedOption == .defaultSetting || validationServiceUrl.isEmpty {
            validationServiceUrl = configuration?.sivaUrl.absoluteString ?? ""
            validationServiceURL = configuration?.sivaUrl
        }

        await dataStore.setValidationServiceURL(validationServiceURL: validationServiceUrl)
        guard let validationServiceURL else { return }
        await DigiDocConf.setSiVaUrl(validationServiceURL)
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
            certificateFolder: CommonsLib.Constants.Folder.SivaCert,
            certificateBaseName: CommonsLib.Constants.FileBaseName.SiVaCert
        )
        if let sivaCertData = sivaCertData {
            await DigiDocConf.addSiVaCert(sivaCertData)
        }
    }

    // MARK: - Observer

    public func observeConfigurationUpdates() async {
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
