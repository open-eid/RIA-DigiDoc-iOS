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
import CryptoSwift
import nfclib
import LibdigidocLibSwift
import CommonsLib

/// @mockable
@MainActor
public protocol NFCViewModelProtocol: Sendable {
    func isActionEnabled(
        canNumber: String,
        pinNumber: String,
        pinType: CodeType?,
        actionType: ActionType?
    ) -> Bool

    func saveInputData(
        canNumber: String,
        rememberMe: Bool,
        actionType: ActionType,
        isWebEidAuthenticating: Bool
    ) async

    func getInputData(_ actionType: ActionType, _ isWebEidAuthenticating: Bool) async -> NFCInputData

    func saveCAN(_ can: String) async
    func retrieveCAN() async -> String?
    func clearCAN() async

    func saveTempCAN(_ can: String) async
    func retrieveTempCAN() async -> String?
    func clearTempCAN() async

    func getSigningCertificate() async -> String
    func setSigningCertificate(_ cert: String) async

    func resetErrors()

    func isRoleDataEnabled() async -> Bool

    func decrypt(
        CAN: String,
        pin1: String,
        cryptoContainer: CryptoContainerProtocol?,
        strings: NFCSessionStrings
    ) async -> CryptoContainerProtocol?

    func sign(
        canNumber: String,
        pin2: String,
        roleData: RoleData,
        signedContainer: SignedContainerProtocol,
        strings: NFCSessionStrings
    ) async -> SignedContainerProtocol?

    // swiftlint:disable:next function_parameter_count
    func signWebEid(
        canNumber: String,
        pin2: String,
        responseUri: String,
        hash: String,
        expectedSigningCertBase64: String?,
        strings: NFCSessionStrings
    ) async -> WebEidSignReturnData?

    func auth(
        canNumber: String,
        pin1: String,
        origin: String,
        challenge: String,
        strings: NFCSessionStrings
    ) async -> WebEidAuthReturnData?

    func certificate(
        canNumber: String,
        strings: NFCSessionStrings
    ) async -> String?

    func saveMyEidCAN(_ can: String)

    func readCardData(
        CAN: String,
        strings: NFCSessionStrings
    ) async -> IdCardData?
}
