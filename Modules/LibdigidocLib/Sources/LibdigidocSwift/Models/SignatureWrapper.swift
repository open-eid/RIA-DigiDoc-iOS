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
    public var signingCert: Data
    public var timestampCert: Data
    public var ocspCert: Data
    public var signatureId: String
    public var claimedSigningTime: String
    public var signatureMethod: String
    public var ocspProducedAt: String
    public var timeStampTime: String
    public var signedBy: String
    public var trustedSigningTime: String

    public var status: SignatureStatus
    public var diagnosticsInfo: String

    init(signingCert: Data,
         timestampCert: Data,
         ocspCert: Data,
         signatureId: String,
         claimedSigningTime: String,
         signatureMethod: String,
         ocspProducedAt: String,
         timeStampTime: String,
         signedBy: String,
         trustedSigningTime: String,
         status: SignatureStatus = .unknown,
         diagnosticsInfo: String) {
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
        self.status = status
        self.diagnosticsInfo = diagnosticsInfo
    }
}
