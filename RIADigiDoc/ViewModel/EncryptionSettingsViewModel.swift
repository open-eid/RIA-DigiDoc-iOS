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
import CryptoObjCWrapper
import Foundation
import UtilsLib

@Observable
@MainActor
class EncryptionSettingsViewModel: EncryptionSettingsViewModelProtocol, Loggable {
    var configuration: ConfigurationProvider?
    var certData: Data?
    var encryptionCdocOption: EncryptionCdocOption = .cdoc1
    var useKeyTransfer: Bool = false
    var serverId: String = Constants.CryptoDefaultValues.encryptionServerInfoUUID
    var cdoc2ManualKeyTransferServerUUID = "00000000-0000-0000-0000-100000000000"
    var serverInfo: EncryptionServerInfo = EncryptionServerInfo()
    var isImportingCert: Bool = false
    var isLoading: Bool = true

    // MARK: - Dependencies
    private let configurationRepository: ConfigurationRepositoryProtocol
    private let dataStore: DataStoreProtocol
    private let advancedSettingsRepository: AdvancedSettingsRepositoryProtocol
    private let certificateUtil: CertificateUtilProtocol
    private let cryptoSetup: CryptoSetupProtocol

    init(
        configurationRepository: ConfigurationRepositoryProtocol,
        dataStore: DataStoreProtocol,
        advancedSettingsRepository: AdvancedSettingsRepositoryProtocol,
        certificateUtil: CertificateUtilProtocol,
        cryptoSetup: CryptoSetupProtocol,
    ) {
        self.configurationRepository = configurationRepository
        self.dataStore = dataStore
        self.advancedSettingsRepository = advancedSettingsRepository
        self.certificateUtil = certificateUtil
        self.cryptoSetup = cryptoSetup

        Task {
            await initializeSettings()
        }
    }

    // MARK: - Init helpers

    public func initializeSettings() async {
        configuration = await configurationRepository.getConfiguration()
        await loadSettings()
        await loadCert()

        isLoading = false
    }

    private func loadCert() async {
        certData = await advancedSettingsRepository.getCertificate(
            certificateFolder: CommonsLib.Constants.Folder.EncryptionKeyTransferCert,
            certificateBaseName: CommonsLib.Constants.FileBaseName.EncryptionKeyTransferCert,
        )
    }

    private func loadSettings() async {
        self.encryptionCdocOption = await dataStore.getEncryptionCdocOption(
            configuration?.cdoc2Default ?? false
        )
        self.useKeyTransfer = await dataStore.getEncryptionUseKeyTransfer(
            configuration?.cdoc2UseKeyserver ?? false
        )

        let cdoc2ConfKeys = configuration?.cdoc2Conf.keys
        let defaultKeyserver = configuration?.cdoc2DefaultKeyserver ??
            (configuration?.cdoc2Conf.keys.first ?? "")
        self.serverId = await dataStore.getEncryptionServerId(defaultKeyserver)
        if cdoc2ConfKeys?.contains(serverId) == false {
            self.serverInfo = await dataStore.getEncryptionServerInfo(cdoc2ManualKeyTransferServerUUID)
            return
        }
        serverInfo = await dataStore.getCentralCDOC2Conf(
            self.serverId,
            configuration: configuration
        )
    }

    public func refreshServerInfo() async {
        if serverId != cdoc2ManualKeyTransferServerUUID {
            serverInfo = await dataStore.getCentralCDOC2Conf(
                self.serverId,
                configuration: configuration
            )
        } else {
            serverInfo = await dataStore.getEncryptionServerInfo(cdoc2ManualKeyTransferServerUUID)
        }
    }

    public func getServerOptions() -> [EncryptionServerOption] {
        var serverOptions: [EncryptionServerOption] = []

        if let cdoc2Conf = configuration?.cdoc2Conf {
            let allKeys = cdoc2Conf.keys
            for uuid in allKeys {
                let conf = cdoc2Conf[uuid]
                let name = conf?.name ?? "Unknown"
                let serverOption: EncryptionServerOption = EncryptionServerOption(
                    id: uuid,
                    titleKey: name,
                    accessibilityInputLabel: name
                )

                serverOptions.append(serverOption)
            }
        }

        let cdoc2ManualKeyTransferServerUUID = "00000000-0000-0000-0000-00000000000"
            + (serverOptions.count + 1).description

        self.cdoc2ManualKeyTransferServerUUID = cdoc2ManualKeyTransferServerUUID

        serverOptions.append(EncryptionServerOption(
            id: cdoc2ManualKeyTransferServerUUID,
            titleKey: "Main settings crypto server option manual",
            accessibilityInputLabel: "Manual"
        ))

        let sorted = serverOptions.sorted(by: { $0.id < $1.id })
        return sorted
    }

    // MARK: - Setters

    public func saveSettings() async {
        await dataStore.setEncryptionCdocOption(encryptionCdocOption)
        if encryptionCdocOption == .cdoc1 {
            useKeyTransfer = false
        }

        await dataStore.setEncryptionUseKeyTransfer(useKeyTransfer)
        let cdoc2DefaultKeyserver = configuration?.cdoc2DefaultKeyserver ??
        (configuration?.cdoc2Conf.keys.first ?? Constants.CryptoDefaultValues.encryptionServerInfoUUID)

        if useKeyTransfer == false {
            serverId = cdoc2DefaultKeyserver
        }

        await dataStore.setEncryptionServerId(serverId)

        let centralConfServerInfo = await dataStore.getCentralCDOC2Conf(
            cdoc2DefaultKeyserver,
            configuration: configuration
        )
        if serverId == cdoc2DefaultKeyserver {
            serverInfo = centralConfServerInfo
        } else {
            serverInfo.uuid = serverInfo.uuid.trimmingCharacters(in: .whitespacesAndNewlines)
            serverInfo.name = serverInfo.name.trimmingCharacters(in: .whitespacesAndNewlines)
            serverInfo.fetchURL = serverInfo.fetchURL.trimmingCharacters(in: .whitespacesAndNewlines)
            serverInfo.postURL = serverInfo.postURL.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        await dataStore.setEncryptionServerInfo(serverInfo)
        await cryptoSetup.setCdoc2Settings(configuration)
        await cryptoSetup.setCdoc2CustomCert(certData)
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
}
