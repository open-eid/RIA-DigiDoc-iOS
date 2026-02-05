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

import Foundation
import CryptoObjCWrapper
import CryptoSwift
import CommonsLib
import ConfigLib

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

    public func setCdoc2Settings(_ configurationProvider: ConfigurationProvider?, _ certData: Data? = nil) async {
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
        await CDoc2Setting.setOnlineEncryptionEnabled(
            await dataStore.getEncryptionUseKeyTransfer(defaultUseCdoc2Online)
        )
        
        if let cdoc2UUID = configurationProvider?.cdoc2DefaultKeyserver {
            let serverInfo = await dataStore.getEncryptionServerInfo(cdoc2UUID)
            await CDoc2Setting.setUUID(serverInfo.uuid)
            await CDoc2Setting.setFetchURL(serverInfo.fetchURL)
            await CDoc2Setting.setPostURL(serverInfo.postURL)
        }
        if let cdoc2Conf = configurationProvider?.cdoc2Conf {
            await CDoc2Setting.setCDoc2Conf(cdoc2Conf)
        }
        
        let proxyInfo = await proxyUtil.getProxyInfo()
        await CDoc2Setting.setProxyInfo(proxyInfo)
        
        if let certBundle = configurationProvider?.certBundle {
            await CDoc2Setting.setCertBundle(certBundle)
        }
        
        if let certData {
            await CDoc2Setting.setCert(certData)
        }
    }

}
