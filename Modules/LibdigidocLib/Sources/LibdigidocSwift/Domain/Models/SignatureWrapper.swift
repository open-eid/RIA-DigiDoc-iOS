// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

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
                archiveTimestampCert: Data = Data()) {
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
    }
}
