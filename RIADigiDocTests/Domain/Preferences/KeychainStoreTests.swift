// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import CommonsLib
import Foundation
import Testing

final class KeychainStoreTests {
    private let keychainStore: KeychainStoreProtocol

    init() {
        let testBundleName = "ee.ria.keychainStoreTests.\(UUID().uuidString)"
        keychainStore = KeychainStore(bundleIdentifier: testBundleName)
    }

    @Test
    func save_success() async throws {
        let key: KeychainKey = .proxyPassword
        let testData = Data("test-initial".utf8)

        let status = await keychainStore.save(key: key, info: testData)
        let retrievedData = await keychainStore.retrieve(key: key)

        #expect(status == true)
        #expect(testData == retrievedData)
    }

    @Test
    func save_successWithOverridingExistingKey() async throws {
        let key: KeychainKey = .proxyPassword

        let testInitialData = Data("test-initial".utf8)
        let testNewData = Data("test-new".utf8)

        var status = await keychainStore.save(key: key, info: testInitialData)
        #expect(status == true)

        status = await keychainStore.save(key: key, info: testNewData)

        let retrievedData = await keychainStore.retrieve(key: key)
        #expect(testNewData == retrievedData)
    }

    @Test
    func remove_success() async throws {
        let key: KeychainKey = .proxyPassword
        let testInitialData = Data("test-initial".utf8)

        let status = await keychainStore.save(key: key, info: testInitialData)
        #expect(status == true)

        await keychainStore.remove(key: key)

        let retrievedData = await keychainStore.retrieve(key: key)

        #expect(retrievedData == nil)
    }

    @Test
    func removeAll_success() async throws {
        let testInitialData = Data("test-initial".utf8)

        for key in KeychainKey.allCases {
            _ = await keychainStore.save(key: key, info: testInitialData)
        }

        await keychainStore.removeAll()

        for key in KeychainKey.allCases {
            let retrievedData = await keychainStore.retrieve(key: key)
            #expect(retrievedData == nil)
        }
    }

    @Test
    func removeAll_removesDynamicallyNamedKeys() async throws {
        let dynamicKey = "\(KeychainKey.signingCertKey.rawValue)_123456"

        let status = await keychainStore.save(key: dynamicKey, info: Data("test-cert".utf8))
        #expect(status == true)

        let storedBeforeRemoval = await keychainStore.retrieve(key: dynamicKey)
        #expect(storedBeforeRemoval != nil)

        await keychainStore.removeAll()

        let storedAfterRemoval = await keychainStore.retrieve(key: dynamicKey)
        #expect(storedAfterRemoval == nil)
    }

}
