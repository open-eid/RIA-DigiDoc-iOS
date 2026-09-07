// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import CommonsLib
import LibdigidocLibSwift

/// @mockable
@MainActor
public protocol SigningRootViewModelProtocol: Sendable {
    func getSelectedSigningMethod() async -> ActionMethod
    func applySignedContainer(
        _ signedContainer: SignedContainerProtocol,
        replacing containerBeingSigned: GeneralContainer?
    )
}
