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
import Foundation
import OSLog

@MainActor
class EncryptionSettingsViewModel: EncryptionSettingsViewModelProtocol, ObservableObject {
    private static let logger = Logger(
        subsystem: "ee.ria.digidoc.RIADigiDoc", category: "EncryptionSettingsViewModel")

    @Published var configuration: ConfigurationProvider?
    @Published var certData: Data?
    @Published var encryptionCdocOption: EncryptionCdocOption = .cdoc1
    @Published var useKeyTransfer: Bool = false
    @Published var serverId: EncryptionServerOptionId = .defaultSetting
    @Published var serverInfo: EncryptionServerInfo = EncryptionServerInfo()
    @Published var isImportingCert: Bool = false
    @Published var isLoading: Bool = true

    // MARK: - Dependencies
    private let configurationRepository: ConfigurationRepositoryProtocol
    private let dataStore: DataStoreProtocol
    private let advancedSettingsRepository: AdvancedSettingsRepositoryProtocol
    private let certificateUtil: CertificateUtilProtocol

    private var configurationObservationTask: Task<Void, Never>?

    init(
        configurationRepository: ConfigurationRepositoryProtocol,
        dataStore: DataStoreProtocol,
        advancedSettingsRepository: AdvancedSettingsRepositoryProtocol,
        certificateUtil: CertificateUtilProtocol
    ) {
        self.configurationRepository = configurationRepository
        self.dataStore = dataStore
        self.advancedSettingsRepository = advancedSettingsRepository
        self.certificateUtil = certificateUtil

        configurationObservationTask = Task {
            await observeConfigurationUpdates()
        }

        Task {
            await initializeSettings()
        }
    }

    // MARK: - Init helpers

    public func initializeSettings() async {
        await ensureConfigurationLoaded()
        await loadSettings()
        await loadCert()

        isLoading = false
    }

    private func ensureConfigurationLoaded() async {
        if configuration == nil {
            for await config in $configuration.values where config != nil {
                break
            }
        }
    }

    private func loadCert() async {
        certData = await advancedSettingsRepository.getCertificate(
            certificateFolder: CommonsLib.Constants.Folder.EncryptionKeyTransferCert,
            certificateBaseName: CommonsLib.Constants.FileBaseName.EncryptionKeyTransferCert,
        )
    }

    private func loadSettings() async {
        self.encryptionCdocOption = await dataStore.getEncryptionCdocOption()
        self.useKeyTransfer = await dataStore.getEncryptionUseKeyTransfer()
        self.serverId = await dataStore.getEncryptionServerId()
        if serverId == .manualSetting {
            self.serverInfo = await dataStore.getEncryptionServerInfo()
            return
        }
        serverInfo = getCentralCDOC2Conf()
    }

    private func getCentralCDOC2Conf() -> EncryptionServerInfo {
        let confServerInfo = configuration?.cdoc2Conf
        let riaUUID = confServerInfo?.keys.first ?? ""
        let riaConf = confServerInfo?[riaUUID]
        return EncryptionServerInfo(
            uuid: riaUUID,
            fetchURL: riaConf?.fetchURL.absoluteString ?? "",
            postURL: riaConf?.postURL.absoluteString ?? ""
        )
    }

    // MARK: - Setters

    public func saveSettings() async {
        await dataStore.setEncryptionCdocOption(encryptionCdocOption)
        if encryptionCdocOption == .cdoc1 {
            useKeyTransfer = false
        }

        await dataStore.setEncryptionUseKeyTransfer(useKeyTransfer)
        if useKeyTransfer == false {
            serverId = .defaultSetting
        }

        await dataStore.setEncryptionServerId(serverId)

        let centralConfServerInfo = getCentralCDOC2Conf()
        if serverId == .defaultSetting {
            serverInfo = centralConfServerInfo
        } else {
            serverInfo.uuid = serverInfo.uuid.trimmingCharacters(in: .whitespacesAndNewlines)
            serverInfo.fetchURL = serverInfo.fetchURL.trimmingCharacters(in: .whitespacesAndNewlines)
            serverInfo.postURL = serverInfo.postURL.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        await dataStore.setEncryptionServerInfo(serverInfo)
    }

    // MARK: - Cert Info Getters

    public func getCertIssuer() -> String {
        guard let cert = certData else { return "" }
        return certificateUtil.getSubjectAttribute(cert: cert, attribute: .RDNAttributeType.commonName)
    }

    public func getCertNotValidAfter(
        expiredLabel: String
    ) -> String {
        guard let cert = certData else { return "" }
        return certificateUtil.getNotValidAfterWithExpiredLabel(
            cert: cert,
            expiredLabel: expiredLabel
        )
    }

    // MARK: - Cert Import

    public func importCert(from url: URL) async {
        certData = await advancedSettingsRepository.importCertificate(
            from: url,
            certificateFolder: CommonsLib.Constants.Folder.EncryptionKeyTransferCert,
            certificateBaseName: CommonsLib.Constants.FileBaseName.EncryptionKeyTransferCert
        )
    }

    // MARK: - Observer

    public func observeConfigurationUpdates() async {
        guard !Task.isCancelled else {
            return
        }

        guard let configStream = await configurationRepository.observeConfigurationUpdates() else {
            EncryptionSettingsViewModel.logger.error("Unable to get configuration updates stream")
            return
        }

        do {
            for try await config in configStream {
                await MainActor.run {
                    configuration = config
                }
            }
        } catch {
            EncryptionSettingsViewModel.logger.error("Unable to get configuration from stream")
        }
    }

    public func removeObservers() async {
        configurationObservationTask?.cancel()
    }
}
