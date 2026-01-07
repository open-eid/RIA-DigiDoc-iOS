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
