// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import CommonsLib
import ConfigLib
import LibdigidocLibSwift
import LibdigidocLibObjC
import UniformTypeIdentifiers
import UtilsLib

@Observable
@MainActor
class TimeStampSettingsViewModel: TimeStampSettingsViewModelProtocol, Loggable {
    // MARK: - Variables
    var configuration: ConfigurationProvider?
    var tsaUrl: String = ""
    var selectedOption: ServicesSettingsOption = .defaultSetting
    var tsaCertData: Data?
    var isImportingTSACert: Bool = false
    var isLoading: Bool = true

    // MARK: - Dependencies
    private let configurationRepository: ConfigurationRepositoryProtocol
    private let dataStore: DataStoreProtocol
    private let fileManager: FileManagerProtocol
    private let advancedSettingsRepository: AdvancedSettingsRepositoryProtocol
    private let certificateUtil: CertificateUtilProtocol

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

        Task {
            await initializeSettings()
        }
    }

    // MARK: - Init helpers

    public func initializeSettings() async {
        await configuration = configurationRepository.getConfiguration()
        await loadSettings()
        await loadTSACert()

        isLoading = false
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
        var tsaURL: URL? = URL(string: tsaUrl)

        if selectedOption == .defaultSetting || tsaUrl.isEmpty {
            tsaUrl = configuration?.tsaUrl.absoluteString ?? ""
            tsaURL = configuration?.tsaUrl
        }

        await dataStore.setTSAUrl(tsaUrl: tsaUrl)
        DigiDocConf.setTSAInfo(
            url: tsaURL,
            cert: tsaCertData,
            option: selectedOption
        )
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
    }
}
