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

public enum SignatureWarning: Sendable, Hashable {
    case referenceDigestWeak
    case signatureDigestWeak
    case dataFileNameSpace
    case issuerNameSpace
    case producedATLate
    case mimeType
    case other
}

public enum SignatureStatus: String, Sendable {
    case valid
    case warning
    case nonQSCD
    case invalid
    case unknown
}

public struct SignatureWrapper: Sendable, Identifiable, Hashable {
    public var id: UUID = UUID()
    public var pos: Int
    public var signingCert: Data
    public var timestampCert: Data
    public var ocspCert: Data
    public var signatureId: String
    public var claimedSigningTime: String
    public var signatureMethod: String
    public var ocspProducedAt: String
    public var timeStampTime: String
    public var signedBy: String
    public var format: String
    public var messageImprint: Data
    public var trustedSigningTime: String

    public var roles: [String]
    public var city: String
    public var state: String
    public var country: String
    public var zipCode: String

    public var status: SignatureStatus
    public var diagnosticsInfo: String

    public var archiveTimestampTime: String
    public var archiveTimestampCert: Data

    private static let weakDigestWarnings: Set<SignatureWarning> = [
        .referenceDigestWeak,
        .signatureDigestWeak
    ]

    public var warnings: [SignatureWarning]

    public var hasOnlyWeakDigestWarnings: Bool {
        !warnings.isEmpty && warnings.allSatisfy { SignatureWrapper.weakDigestWarnings.contains($0) }
    }

    public var isLTAExtended: Bool {
        !archiveTimestampCert.isEmpty
    }

    public init(pos: Int,
                signingCert: Data,
                timestampCert: Data,
                ocspCert: Data,
                signatureId: String,
                claimedSigningTime: String,
                signatureMethod: String,
                ocspProducedAt: String,
                timeStampTime: String,
                signedBy: String,
                trustedSigningTime: String,
                roles: [String],
                city: String,
                state: String,
                country: String,
                zipCode: String,
                status: SignatureStatus = .unknown,
                format: String,
                messageImprint: Data,
                diagnosticsInfo: String,
                archiveTimestampTime: String = "",
                archiveTimestampCert: Data = Data(),
                warnings: [SignatureWarning] = []) {
        self.pos = pos
        self.signingCert = signingCert
        self.timestampCert = timestampCert
        self.ocspCert = ocspCert
        self.signatureId = signatureId
        self.claimedSigningTime = claimedSigningTime
        self.signatureMethod = signatureMethod
        self.ocspProducedAt = ocspProducedAt
        self.timeStampTime = timeStampTime
        self.signedBy = signedBy
        self.trustedSigningTime = trustedSigningTime
        self.roles = roles
        self.city = city
        self.state = state
        self.country = country
        self.zipCode = zipCode
        self.status = status
        self.format = format
        self.messageImprint = messageImprint
        self.diagnosticsInfo = diagnosticsInfo
        self.archiveTimestampTime = archiveTimestampTime
        self.archiveTimestampCert = archiveTimestampCert
        self.warnings = warnings
    }
}
