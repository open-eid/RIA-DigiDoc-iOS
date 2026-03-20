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

final class ProxyUtilTests {
    private let proxyUtil: ProxyUtil

    private let mockDataStore: DataStoreProtocolMock!
    private let mockKeychainStore: KeychainStoreProtocolMock!

    init() {
        mockDataStore = DataStoreProtocolMock()
        mockKeychainStore = KeychainStoreProtocolMock()
        proxyUtil = ProxyUtil(dataStore: mockDataStore, keychainStore: mockKeychainStore)
    }

    @Test
    func isPortValid_successValid() { #expect(proxyUtil.isPortValid(80)) }

    @Test
    func isPortValid_returnsFalseWithInvalidSmall() { #expect(!proxyUtil.isPortValid(0)) }

    @Test
    func isPortValid_returnsFalseWithInvalidNegative() { #expect(!proxyUtil.isPortValid(-500)) }

    @Test
    func isPortValid_returnsFalseWithInvalidBig() { #expect(!proxyUtil.isPortValid(65536)) }

    @Test
    func getProxyInfo_successWithDisabledOption() async throws {
        let testInfo = ProxyInfo(
            option: .disabled,
            host: "",
            port: 80,
            username: "",
            password: ""
        )
        let expectedPassword = ""

        mockDataStore.getProxyInfoHandler = {
            testInfo
        }

        mockKeychainStore.retrieveHandler = { _ in
            Data(expectedPassword.utf8)
        }
        let result = await proxyUtil.getProxyInfo()
        #expect(result.option == testInfo.option)
        #expect(result.host == testInfo.host)
        #expect(result.port == testInfo.port)
        #expect(result.username == testInfo.username)
        #expect(result.password == expectedPassword)
    }

    @Test
    func getProxyInfo_successWithSystemOption() async throws {
        let testInfo = ProxyInfo(
            option: .system,
            host: "testHost",
            port: 1234,
            username: "testUser",
            password: ""
        )
        let expectedPassword = "testPassword"

        mockDataStore.getProxyInfoHandler = {
            testInfo
        }

        mockKeychainStore.retrieveHandler = { _ in
            Data(expectedPassword.utf8)
        }
        let result = await proxyUtil.getProxyInfo()
        #expect(result.option == testInfo.option)
        #expect(result.host == "")
        #expect(result.port == 80)
        #expect(result.username == "")
        #expect(result.password == "")
    }

    @Test
    func getProxyInfo_successWithManualOption() async throws {
        let testInfo = ProxyInfo(
            option: .manual,
            host: "testHost",
            port: 1234,
            username: "testUser",
            password: ""
        )
        let expectedPassword = "testPassword"

        mockDataStore.getProxyInfoHandler = {
            testInfo
        }

        mockKeychainStore.retrieveHandler = { _ in
            Data(expectedPassword.utf8)
        }
        let result = await proxyUtil.getProxyInfo()
        #expect(result.option == testInfo.option)
        #expect(result.host == testInfo.host)
        #expect(result.port == testInfo.port)
        #expect(result.username == testInfo.username)
        #expect(result.password == expectedPassword)
    }

    @Test
    func saveSetting_successWithDisabledOption() async throws {
        let testInfo = ProxyInfo(
            option: .disabled,
            host: "testHost",
            port: 1234,
            username: "testUser",
            password: "testPassword"
        )
        await proxyUtil.saveSetting(proxyInfo: testInfo)
        #expect(mockDataStore.setProxyInfoCallCount == 1)
        #expect(mockKeychainStore.saveKeyCallCount == 0)
    }

    @Test
    func saveSetting_successWithSystemOption() async throws {
        let testInfo = ProxyInfo(
            option: .system,
            host: "testHost",
            port: 1234,
            username: "testUser",
            password: "testPassword"
        )
        await proxyUtil.saveSetting(proxyInfo: testInfo)
        #expect(mockDataStore.setProxyInfoCallCount == 1)
        #expect(mockKeychainStore.saveKeyCallCount == 0)
    }

    @Test
    func saveSetting_successWithManualOption() async throws {
        let testInfo = ProxyInfo(
            option: .manual,
            host: "testHost",
            port: 1234,
            username: "testUser",
            password: "testPassword"
        )
        await proxyUtil.saveSetting(proxyInfo: testInfo)
        #expect(mockDataStore.setProxyInfoCallCount == 1)
        #expect(mockKeychainStore.saveKeyCallCount == 1)
    }
}
