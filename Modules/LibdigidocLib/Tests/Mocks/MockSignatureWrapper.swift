import Foundation
import LibdigidocLibSwift

public struct MockSignatureWrapper {
    public static func mockSignatureWrapper(
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
