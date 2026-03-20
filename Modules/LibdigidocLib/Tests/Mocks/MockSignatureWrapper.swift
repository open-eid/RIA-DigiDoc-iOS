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
import LibdigidocLibSwift

public struct MockSignatureWrapper {
    public static func mockSignatureWrapper(
        pos: Int = 0,
        signingCert: Data = Data(),
        timestampCert: Data = Data(),
        ocspCert: Data = Data(),
        signatureId: String = "S1",
        claimedSigningTime: String = "1970-01-01T00:00:00Z",
        signatureMethod: String = "signature-method",
        ocspProducedAt: String = "1970-01-01T00:00:00Z",
        timeStampTime: String = "1970-01-01T00:00:00Z",
        signedBy: String = "Test User",
        trustedSigningTime: String = "1970-01-01T00:00:00Z",
        roles: [String] = ["Role 1", "Role 2"],
        city: String = "Test City",
        state: String = "Test State",
        country: String = "Test Country",
        zipCode: String = "Test12345",
        status: SignatureStatus = .valid,
        format: String = "BES/time-stamp",
        messageImprint: Data = Data(),
        diagnosticsInfo: String = ""
    ) -> SignatureWrapper {
        SignatureWrapper(
            pos: pos,
            signingCert: signingCert,
            timestampCert: timestampCert,
            ocspCert: ocspCert,
            signatureId: signatureId,
            claimedSigningTime: claimedSigningTime,
            signatureMethod: signatureMethod,
            ocspProducedAt: ocspProducedAt,
            timeStampTime: timeStampTime,
            signedBy: signedBy,
            trustedSigningTime: trustedSigningTime,
            roles: roles,
            city: city,
            state: state,
            country: country,
            zipCode: zipCode,
            status: status,
            format: format,
            messageImprint: messageImprint,
            diagnosticsInfo: diagnosticsInfo
        )
    }
}
