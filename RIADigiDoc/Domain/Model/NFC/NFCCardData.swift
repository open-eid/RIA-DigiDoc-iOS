// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import nfclib

public struct NFCCardData: Sendable {
    let publicData: CardInfo
    let authenticationCertificate: Data?
    let signatureCertificate: Data?
    let pinResponse: PinResponse
    let isPUKChangable: Bool
}
