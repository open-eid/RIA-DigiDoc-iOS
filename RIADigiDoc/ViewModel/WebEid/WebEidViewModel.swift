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

import Foundation
import UtilsLib
import WebEidLib

@Observable
@MainActor
class WebEidViewModel: WebEidViewModelProtocol, Loggable {

    var errorKey: String?
    var errorExtraArguments: [String] = []
    var errorEventId: Int = 0

    var showAlertMessage: Bool = false
    var alertMessageKey: String?
    var alertMessageExtraArguments: [String] = []
    var alertMessageUrl: String?

    var authRequest: WebEidAuthRequest?
    var signRequest: WebEidSignRequest?
    var certRequest: WebEidCertificateRequest?

    var relyingPartyResponseEvents: URL?

    private var hasRespondedToRelyingParty = false

    private let authService: WebEidAuthServiceProtocol
    private let signService: WebEidSignServiceProtocol
    private let keychainStore: KeychainStoreProtocol
    let dataStore: DataStoreProtocol

    init(
        dataStore: DataStoreProtocol,
        keychainStore: KeychainStoreProtocol,
        authService: WebEidAuthServiceProtocol,
        signService: WebEidSignServiceProtocol
    ) {
        self.dataStore = dataStore
        self.keychainStore = keychainStore
        self.authService = authService
        self.signService = signService
    }

    func handleAuth(url: URL) {
        hasRespondedToRelyingParty = false
        do {
            let request = try WebEidRequestParser.parseAuthURL(url)
            resetRequests()
            authRequest = request
        } catch {
            handleRequestParsingFailure(error, fallbackErrorKey: "Invalid authentication request")
        }
    }

    func handleCertificate(url: URL) {
        hasRespondedToRelyingParty = false
        do {
            let request = try WebEidRequestParser.parseCertificateURL(url)
            resetRequests()
            certRequest = request
        } catch {
            handleRequestParsingFailure(error, fallbackErrorKey: "Invalid Web eID request")
        }
    }

    func handleSign(url: URL) {
        hasRespondedToRelyingParty = false
        do {
            let request = try WebEidRequestParser.parseSignURL(url)
            resetRequests()
            signRequest = request
        } catch {
            handleRequestParsingFailure(error, fallbackErrorKey: "Invalid Web eID request")
        }
    }

    func handleUnknown(url: URL) {
        hasRespondedToRelyingParty = false
        WebEidViewModel.logger().error("Unable to parse Web eID request from \(url.host ?? "-")")
        reportError("Invalid Web eID request")
    }

    private func sendResponse(_ url: URL) {
        guard !hasRespondedToRelyingParty else {
            WebEidViewModel.logger().error("Ignoring duplicate Web eID response")
            return
        }

        hasRespondedToRelyingParty = true
        relyingPartyResponseEvents = url
    }

    private func reportError(_ key: String, arguments: [String] = []) {
        errorKey = key
        errorExtraArguments = arguments
        errorEventId += 1
    }

    private func resetRequests() {
        resetErrors()
        authRequest = nil
        certRequest = nil
        signRequest = nil
    }

    private func handleRequestParsingFailure(_ error: Error, fallbackErrorKey: String) {
        guard let webEidException = error as? WebEidException else {
            WebEidViewModel.logger().error("Unable to parse Web eID request")
            reportError(fallbackErrorKey)
            return
        }

        WebEidViewModel.logger().error("Invalid Web eID request: \(webEidException.code.rawValue)")

        guard !webEidException.responseUri.isEmpty else {
            reportError(fallbackErrorKey)
            return
        }

        let errorPayload = WebEidResponseUtil.createErrorPayload(
            code: webEidException.code,
            message: webEidException.message
        )

        do {
            let errorURL = try WebEidResponseUtil.createResponseURL(
                responseUri: webEidException.responseUri,
                payload: errorPayload
            )
            sendResponse(errorURL)
        } catch {
            WebEidViewModel.logger().error(
                "Unable to build Web eID error response: \(error.localizedDescription)"
            )
            reportError(fallbackErrorKey)
        }
    }

    func handleWebEidAuthResult(
        authCert: Data,
        signingCert: Data,
        signature: Data
    ) async {
        guard let authRequest else { return }

        let loginUri = authRequest.loginUri
        let getSigningCertificate = authRequest.getSigningCertificate

        do {
            let tokenData = try await authService.buildAuthToken(
                authCert: authCert,
                signingCert: getSigningCertificate ? signingCert : nil,
                signature: signature
            )

            let tokenObject = try JSONSerialization.jsonObject(with: tokenData, options: [])

            let payload: [String: Any] = [
                "authToken": tokenObject
            ]

            let responseURL = try WebEidResponseUtil.createResponseURL(
                responseUri: loginUri,
                payload: payload
            )

            sendResponse(responseURL)
        } catch {
            WebEidViewModel.logger().error("Unexpected error building auth token: \(String(reflecting: error))")

            let errorPayload = WebEidResponseUtil.createErrorPayload(
                code: .ERR_WEBEID_MOBILE_UNKNOWN_ERROR,
                message: "Unexpected error"
            )

            do {
                let responseURL = try WebEidResponseUtil.createResponseURL(
                    responseUri: loginUri,
                    payload: errorPayload
                )
                sendResponse(responseURL)
            } catch {
                WebEidViewModel.logger().error("Failed to build error response URL: \(String(reflecting: error))")
            }
        }
    }

    func handleWebEidCertificateResult(signingCert: Data) async {
        guard let responseUri = certRequest?.responseUri,
              !responseUri.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            WebEidViewModel.logger().error("Missing responseUri in sign payload for certificate step")
            return
        }

        do {
            let payloadData = try await signService.buildCertificatePayload(signingCert: signingCert)
            let payloadObject = try JSONSerialization.jsonObject(with: payloadData, options: [])

            guard let payload = payloadObject as? [String: Any] else {
                WebEidViewModel.logger().error("Invalid certificate payload JSON")
                return
            }

            let responseURL = try WebEidResponseUtil.createResponseURL(
                responseUri: responseUri,
                payload: payload
            )
            sendResponse(responseURL)

        } catch {
            WebEidViewModel.logger().error(
                "Unexpected error building certificate payload: \(String(reflecting: error))"
            )

            let errorPayload = WebEidResponseUtil.createErrorPayload(
                code: .ERR_WEBEID_MOBILE_UNKNOWN_ERROR,
                message: "Unexpected error"
            )

            do {
                let errorURL = try WebEidResponseUtil.createResponseURL(
                    responseUri: responseUri,
                    payload: errorPayload
                )
                sendResponse(errorURL)
            } catch {
                WebEidViewModel.logger().error("Failed to build error response URL: \(String(reflecting: error))")
            }
        }
    }

    func handleWebEidSignResult(
        signingCert: String,
        signature: Data,
        responseUri: String
    ) async {
        do {
            guard let hashFunction = signRequest?.hashFunction,
                  !hashFunction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                WebEidViewModel.logger().error("Missing signRequest")
                return
            }

            let payloadData = try await signService.buildSignPayload(
                signingCert: signingCert,
                signature: signature,
                hashFunction: hashFunction
            )

            let payloadObject = try JSONSerialization.jsonObject(with: payloadData, options: [])

            guard let payload = payloadObject as? [String: Any] else {
                WebEidViewModel.logger().error("Invalid sign payload JSON")
                return
            }

            let responseURL = try WebEidResponseUtil.createResponseURL(
                responseUri: responseUri,
                payload: payload
            )

            sendResponse(responseURL)

        } catch {
            WebEidViewModel.logger().error("Unexpected error building sign payload: \(String(reflecting: error))")

            let errorPayload = WebEidResponseUtil.createErrorPayload(
                code: .ERR_WEBEID_MOBILE_UNKNOWN_ERROR,
                message: "Unexpected error"
            )

            do {
                let errorURL = try WebEidResponseUtil.createResponseURL(
                    responseUri: responseUri,
                    payload: errorPayload
                )
                sendResponse(errorURL)
            } catch {
                WebEidViewModel.logger().error("Failed to build error response URL: \(String(reflecting: error))")
            }
        }
    }

    func handleUserCancelled() async {
        do {
            let responseUri =
                authRequest?.loginUri ??
                certRequest?.responseUri ??
                signRequest?.responseUri

            guard let responseUri,
                  !responseUri.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                Self.logger().error("Cannot send cancel response — missing response URI")
                return
            }

            let errorPayload = WebEidResponseUtil.createErrorPayload(
                code: .ERR_WEBEID_USER_CANCELLED,
                message: "User cancelled"
            )

            let errorURL = try WebEidResponseUtil.createResponseURL(
                responseUri: responseUri,
                payload: errorPayload
            )

            sendResponse(errorURL)
        } catch {
            WebEidViewModel.logger().error("Failed to send cancel response: \(String(reflecting: error))")
        }
    }

    func resetErrors() {
        showAlertMessage = false
        alertMessageKey = nil
        alertMessageExtraArguments = []
        alertMessageUrl = nil
        errorKey = nil
        errorExtraArguments = []
    }

    // MARK: - WebEid KeyChainStore

    func isWebEidSessionActive() async -> Bool {
        if let data = await keychainStore.retrieve(key: .webEidSessionActive) {
            let value = data.first == 1
            return value
        }

        return false
    }

    func setWebEidSessionActive(_ value: Bool) async {
        let data = Data([value ? 1 : 0])

        _ = await keychainStore.save(key: .webEidSessionActive, info: data)
    }
}
