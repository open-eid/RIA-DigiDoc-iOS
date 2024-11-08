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
    public var signingCert: Data?
    public var timestampCert: Data?
    public var ocspCert: Data?
    public var signatureId: String?
    public var claimedSigningTime: String?
    public var signatureMethod: String?
    public var dataToSign: Data?
    public var ocspProducedAt: String?
    public var timeStampTime: String?
    public var signedBy: String?
    public var trustedSigningTime: String?

    public var status: SignatureStatus
    public var diagnosticsInfo: String?

    init(signingCert: Data? = nil,
         timestampCert: Data? = nil,
         ocspCert: Data? = nil,
         signatureId: String? = nil,
         claimedSigningTime: String? = nil,
         signatureMethod: String? = nil,
         dataToSign: Data? = nil,
         ocspProducedAt: String? = nil,
         timeStampTime: String? = nil,
         signedBy: String? = nil,
         trustedSigningTime: String? = nil,
         status: SignatureStatus = .unknown,
         diagnosticsInfo: String? = nil) {
        self.signingCert = signingCert
        self.timestampCert = timestampCert
        self.ocspCert = ocspCert
        self.signatureId = signatureId
        self.claimedSigningTime = claimedSigningTime
        self.signatureMethod = signatureMethod
        self.dataToSign = dataToSign
        self.ocspProducedAt = ocspProducedAt
        self.timeStampTime = timeStampTime
        self.signedBy = signedBy
        self.trustedSigningTime = trustedSigningTime
        self.status = status
        self.diagnosticsInfo = diagnosticsInfo
    }
}
