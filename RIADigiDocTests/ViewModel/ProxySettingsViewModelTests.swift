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

import Alamofire
import CommonsLib
import CommonsTestShared
import Foundation
import Testing
import UtilsLibMocks

@MainActor
final class ProxySettingsViewModelTests {
    private let mockProxyUtil: ProxyUtilProtocolMock
    private let mockUserAgentUtil: UserAgentUtilProtocolMock
    private let mockDataStore: DataStoreProtocolMock

    private let viewModel: ProxySettingsViewModel

    init() {
        mockProxyUtil = ProxyUtilProtocolMock()
        mockUserAgentUtil = UserAgentUtilProtocolMock()
        mockDataStore = DataStoreProtocolMock()

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        viewModel = ProxySettingsViewModel(
            proxyUtil: mockProxyUtil,
            userAgentUtil: mockUserAgentUtil,
            dataStore: mockDataStore
        )
    }

    @Test
    func isPortTextValid_successEmpty() {
        viewModel.portText = ""
        #expect(viewModel.isPortTextValid)
        #expect(mockProxyUtil.isPortValidCallCount == 0)
    }

    @Test
    func isPortTextValid_successInteger() {
        viewModel.portText = "80"
        mockProxyUtil.isPortValidHandler = { _ in true }
        #expect(viewModel.isPortTextValid)
        #expect(mockProxyUtil.isPortValidCallCount == 1)
    }

    @Test
    func isPortTextValid_returnsFalseWithNotInteger() {
        viewModel.portText = "not integer"
        #expect(!viewModel.isPortTextValid)
        #expect(mockProxyUtil.isPortValidCallCount == 0)
    }

    @Test
    func isPortTextValid_returnsFalseWithSmallInteger() {
        viewModel.portText = "0"
        mockProxyUtil.isPortValidHandler = { _ in false }
        #expect(!viewModel.isPortTextValid)
        #expect(mockProxyUtil.isPortValidCallCount == 1)
    }

    @Test
    func isPortTextValid_returnsFalseWithBigInteger() {
        viewModel.portText = "65536"
        mockProxyUtil.isPortValidHandler = { _ in false }
        #expect(!viewModel.isPortTextValid)
        #expect(mockProxyUtil.isPortValidCallCount == 1)
    }

    @Test
    func saveSettings_success() async throws {
        let testInfo = ProxyInfo(
            option: .manual,
            host: "testHost",
            port: 1234,
            username: "testUser",
            password: "testPassword"
        )
        viewModel.proxyInfo = testInfo

        await viewModel.saveSettings()

        #expect(mockProxyUtil.saveSettingCallCount == 1)
        #expect(mockProxyUtil.saveSettingArgValues.first?.option == testInfo.option)
        #expect(mockProxyUtil.saveSettingArgValues.first?.host == testInfo.host)
        #expect(mockProxyUtil.saveSettingArgValues.first?.port == testInfo.port)
        #expect(mockProxyUtil.saveSettingArgValues.first?.username == testInfo.username)
        #expect(mockProxyUtil.saveSettingArgValues.first?.password == testInfo.password)
    }

    @Test
    func checkInternetAccess_success() async throws {
        let session = try await createMockedSession()

        viewModel.proxyInfo = ProxyInfo()

        #expect(await viewModel.checkInternetAccess(session: session) == true)
    }

    @Test
    func checkInternetAccess_returnsFalseWhenRequestFails() async throws {
        let session = try await createMockedSession(returnStatusCode: 400)

        viewModel.proxyInfo = ProxyInfo()

        #expect(await viewModel.checkInternetAccess(session: session) == false)
    }

    @Test
    func checkInternetAccess_successWithSystemProxy() async throws {
        let session = try await createMockedSession()

        let testInfo = ProxyInfo(
            option: .system,
            host: "",
            port: 80,
            username: "",
            password: ""
        )
        mockProxyUtil.getSystemProxyInfoHandler = {
            testInfo
        }
        viewModel.proxyInfo = testInfo

        #expect(await viewModel.checkInternetAccess(session: session) == true)
    }

    private func createMockedSession(
        returnStatusCode: Int = 200
    ) async throws -> Session {
        let mockUrl = URL(string: "https://mockUrl.test/config.json")

        guard let url = mockUrl else {
            throw URLError(.badURL)
        }

        let mockData = Data("signature".utf8)

        let mockResponse = HTTPURLResponse(url: url, statusCode: returnStatusCode, httpVersion: nil, headerFields: nil)

        guard let response = mockResponse else {
            throw URLError(.badServerResponse)
        }

        let session = makeMockedSession { _ in
            return (response, mockData)
        }

        return session
    }
}
