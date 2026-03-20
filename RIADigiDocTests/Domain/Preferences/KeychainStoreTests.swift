/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
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

}
