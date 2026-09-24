// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
