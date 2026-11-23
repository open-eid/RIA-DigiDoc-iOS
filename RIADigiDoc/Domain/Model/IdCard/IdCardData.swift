// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import nfclib

public struct IdCardData: Sendable, Hashable {
    public let publicData: CardInfo
    public let authCertNotValidDate: String?
    public let signCertNotValidDate: String?
    public let authCertNotValidAfter: Date?
    public let signCertNotValidAfter: Date?
    public let pinResponse: PinResponse
    public let isPUKChangeable: Bool
}
