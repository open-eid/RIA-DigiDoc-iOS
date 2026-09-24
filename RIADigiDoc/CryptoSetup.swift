// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import CryptoObjCWrapper
import CryptoSwift
import CommonsLib
import ConfigLib
import CryptoObjC

actor CryptoSetup: CryptoSetupProtocol {
    private let dataStore: DataStoreProtocol
    private let proxyUtil: ProxyUtilProtocol
    private let ldapConfiguration: LdapConfigurationProtocol

    init(
        dataStore: DataStoreProtocol,
        proxyUtil: ProxyUtilProtocol,
        ldapConfiguration: LdapConfigurationProtocol
    ) {
        self.dataStore = dataStore
        self.proxyUtil = proxyUtil
        self.ldapConfiguration = ldapConfiguration
    }

   public func setLdapConfig(_ configurationProvider: ConfigurationProvider?) async {
        if let ldapPersonUrl = configurationProvider?.ldapPersonUrl {
            await ldapConfiguration.setLdapPersonURLS([ldapPersonUrl])
        }

        if let ldapPersonUrls = configurationProvider?.ldapPersonUrls {
            await ldapConfiguration.setLdapPersonURLS(ldapPersonUrls)
        }

        if let ldapCorpUrl = configurationProvider?.ldapCorpUrl {
            await ldapConfiguration.setLdapCorpURL(ldapCorpUrl)
        }
    }

    public func setCdoc2Config(_ configurationProvider: ConfigurationProvider?) async {
        if let useCdoc2Encryption = configurationProvider?.cdoc2Default {
            if await !dataStore.keyExistsUseCdoc2Encryption() {
                await dataStore.setUseCdoc2Encryption(useCdoc2Encryption)
            }
        }

        if let useCdoc2Online = configurationProvider?.cdoc2UseKeyserver {
            if await !dataStore.keyExistsEncryptionUseKeyTransfer() {
                await dataStore.setEncryptionUseKeyTransfer(useCdoc2Online)
            }
        }

        if let cdoc2UUID = configurationProvider?.cdoc2DefaultKeyserver,
           let cdoc2Conf = configurationProvider?.cdoc2Conf {

            let conf = cdoc2Conf[cdoc2UUID]
            if let cdoc2ConfFetchUrl = conf?.fetchURL,
               let cdoc2ConfPostUrl = conf?.postURL,
               let cdoc2ConfName = conf?.name {
                let encryptionServerInfo = await EncryptionServerInfo(
                    uuid: cdoc2UUID,
                    name: cdoc2ConfName,
                    fetchURL: cdoc2ConfFetchUrl.absoluteString,
                    postURL: cdoc2ConfPostUrl.absoluteString
                )

                if await !dataStore.keyExistsEncryptionServerInfo() {
                    await dataStore.setEncryptionServerInfo(encryptionServerInfo)
                }
            }
        }

        if let cdoc2Conf = configurationProvider?.cdoc2Conf {
            let allKeys = cdoc2Conf.keys
            for uuid in allKeys {
                let conf = cdoc2Conf[uuid]
                if let cdoc2ConfFetchUrl = conf?.fetchURL,
                   let cdoc2ConfPostUrl = conf?.postURL {
                    await dataStore.setEncryptionServerInfoFetchURL(
                        cdoc2ConfFetchUrl.absoluteString, domain: uuid)
                    await dataStore.setEncryptionServerInfoPostURL(
                        cdoc2ConfPostUrl.absoluteString, domain: uuid)
                }
            }
        }
    }

    public func setCdoc2Settings(_ configurationProvider: ConfigurationProvider?) async {
        var defaultUseCdoc2Encryption = Constants.CryptoDefaultValues.encryptionUseCdoc2
        if let useCdoc2Encryption = configurationProvider?.cdoc2Default {
            defaultUseCdoc2Encryption = useCdoc2Encryption
        }
        await CDoc2Setting.setEncryptionEnabled(
            await dataStore.getUseCdoc2Encryption(defaultUseCdoc2Encryption)
        )

        var defaultUseCdoc2Online = Constants.CryptoDefaultValues.encryptionUseKeyTransfer
        if let useCdoc2Online = configurationProvider?.cdoc2UseKeyserver {
            defaultUseCdoc2Online = useCdoc2Online
        }
        Encrypt.setIsOnlineEncryptionEnabled(
            await dataStore.getEncryptionUseKeyTransfer(defaultUseCdoc2Online)
        )

        if let cdoc2UUID = configurationProvider?.cdoc2DefaultKeyserver {
            let serverInfo = await dataStore.getEncryptionServerInfo(cdoc2UUID)
            Encrypt.setUUID(serverInfo.uuid)
            Encrypt.setFetchURL(serverInfo.fetchURL)
            Encrypt.setPostURL(serverInfo.postURL)
        }
        if let cdoc2Conf = configurationProvider?.cdoc2Conf {
            Encrypt.setCdoc2Config(cdoc2Conf.asNSDictionary())
            Decrypt.setCdoc2Config(cdoc2Conf.asNSDictionary())
        }

        if let certBundle = configurationProvider?.certBundle {
            Encrypt.setCerts(certBundle)
            Decrypt.setCerts(certBundle)
        }

        let proxyInfo = await proxyUtil.getProxyInfo()
        await setCdoc2ProxyInfo(proxyInfo)
    }

    public func setCdoc2CustomCert(_ certData: Data? = nil) async {
        if let certData {
            Encrypt.setCert(certData)
            Decrypt.setCert(certData)
        }
    }

    public func setCdoc2ProxyInfo(_ proxyInfo: ProxyInfo) async {
        Encrypt.setProxy(
            proxyInfo.host,
            port: proxyInfo.port,
            username: proxyInfo.username,
            password: proxyInfo.password
        )

        Decrypt.setProxy(
            proxyInfo.host,
            port: proxyInfo.port,
            username: proxyInfo.username,
            password: proxyInfo.password
        )
    }
}
