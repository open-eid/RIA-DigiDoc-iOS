// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import CommonsLib
import Foundation
import nfclib
import LibdigidocLibSwift

/// @mockable
@MainActor
public protocol OperationReadCertAndSignProtocol {
    // swiftlint:disable:next function_parameter_count
    func startOperation(
        canNumber: String,
        pin2Number: SecureData,
        signedContainer: SignedContainerProtocol,
        containerPath: URL,
        roleData: RoleData,
        userAgent: String,
        strings: NFCSessionStrings
    ) async throws -> SignedContainerProtocol
}
