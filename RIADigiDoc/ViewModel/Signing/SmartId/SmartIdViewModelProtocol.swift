// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import LibdigidocLibSwift
import CommonsLib

/// @mockable
@MainActor
public protocol SmartIdViewModelProtocol: Sendable {
    func appDidEnterBackground()
    func appDidBecomeActive()
    func isSigningEnabled(
        personalCode: String,
    ) -> Bool

    func saveInputData(
        country: SmartIdCountry,
        personalCode: String,
        rememberMe: Bool
    ) async

    func getInputData() async -> SmartIdInputData

    func resetErrors()

    func sign(
        country: SmartIdCountry,
        personalCode: String,
        roleData: RoleData,
        signedContainer: SignedContainerProtocol,
        liveActivityTexts: SmartIdLiveActivityTexts
    ) async -> SignedContainerProtocol?

    func isRoleDataEnabled() async -> Bool
}
