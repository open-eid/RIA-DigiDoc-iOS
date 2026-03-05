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
    
    var showAlertMessage: Bool = false
    var alertMessageKey: String?
    var alertMessageExtraArguments: [String] = []
    var alertMessageUrl: String?
    
    var authRequest: WebEidAuthRequest?
    var signRequest: WebEidSignRequest?
    var certRequest: WebEidCertificateRequest?
    
    var relyingPartyResponseEvents: URL?
    
    // TODO: implement me
    /*
    private let webEidRepository: WebEidRepositoryProtocol
    private let sharedWebEidSession: SharedWebEidSessionProtocol
    
    init(
        webEidRepository: WebEidRepositoryProtocol,
        sharedWebEidSession: SharedWebEidSessionProtocol
    ) {
        self.webEidRepository = webEidRepository
        self.sharedWebEidSession = sharedWebEidSession
    }
    */
    
    func handleAuth(url: URL) {
        do {
            authRequest = try WebEidRequestParser.parseAuthURL(url)
        } catch {
            if let webEidException = error as? WebEidException {
                WebEidViewModel.logger().error("Invalid Web eID authentication request: \(url)")
                let errorPayload = WebEidResponseUtil.createErrorPayload(code: webEidException.code, message: webEidException.message)
                let responseUri = try? WebEidResponseUtil.createResponseURL(responseUri: webEidException.responseUri, payload: errorPayload)
                relyingPartyResponseEvents = responseUri
            } else {
                WebEidViewModel.logger().error("Unable parse Web eID authentication request: \(url)")
                errorKey = "Invalid authentication request"
                errorExtraArguments = []
            }
        }
    }
    
    func handleCertificate(url: URL) {
        do {
            certRequest = try WebEidRequestParser.parseCertificateURL(url)
        } catch {
            WebEidViewModel.logger().error("Unable parse Web eID certificate request: \(url)")
            errorKey = "Invalid Web eID request"
            errorExtraArguments = []
        }
    }

    func handleSign(url: URL) {
        do {
            signRequest = try WebEidRequestParser.parseSignURL(url)
        } catch {
            if let webEidException = error as? WebEidException {
                WebEidViewModel.logger().error("Invalid Web eID signing request: \(url)")
                let errorPayload = WebEidResponseUtil.createErrorPayload(code: webEidException.code, message: webEidException.message)
                let responseUri = try? WebEidResponseUtil.createResponseURL(responseUri: webEidException.responseUri, payload: errorPayload)
                relyingPartyResponseEvents = responseUri
            } else {
                WebEidViewModel.logger().error("Unable parse Web eID signing request: \(url)")
                errorKey = "Invalid Web eID request"
                errorExtraArguments = []
            }
        }
    }

    func handleUnknown(url: URL) {
        WebEidViewModel.logger().error("Unable parse Web eID request: \(url)")
        errorKey = "Invalid Web eID request"
        errorExtraArguments = []
    }
    
    func resetErrors() {
        showAlertMessage = false
        alertMessageKey = nil
        alertMessageExtraArguments = []
        alertMessageUrl = nil
        errorKey = nil
        errorExtraArguments = []
    }

}
