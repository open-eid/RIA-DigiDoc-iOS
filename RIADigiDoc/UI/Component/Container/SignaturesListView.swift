import SwiftUI
import FactoryKit
import LibdigidocLibSwift
import UtilsLib

struct SignaturesListView: View {
    @AppTheme private var theme
    @AppTypography private var typography

    let signatures: [SignatureWrapper]
    @Binding var selectedSignature: SignatureWrapper?
    @Binding var containerMimetype: String
    var dataFilesCount: Int

    let nameUtil: NameUtilProtocol
    let signatureUtil: SignatureUtilProtocol

    var body: some View {
        List {
            ForEach(signatures) { signature in
                SignatureView(
                    containerMimetype: containerMimetype,
                    dataFilesCount: dataFilesCount,
                    signature: signature,
                    nameUtil: nameUtil,
                    signatureUtil: signatureUtil
                )
            }
        }
        .listStyle(.plain)
    }
}

#Preview {
    let signature = SignatureWrapper(
        signingCert: Data(),
        timestampCert: Data(),
        ocspCert: Data(),
        signatureId: "S1",
        claimedSigningTime: "1970-01-01T00:00:00Z",
        signatureMethod: "signature-method",
        ocspProducedAt: "1970-01-01T00:00:00Z",
        timeStampTime: "1970-01-01T00:00:00Z",
        signedBy: "Test User",
        trustedSigningTime: "1970-01-01T00:00:00Z",
        format: "BES/time-stamp",
        messageImprint: Data(),
        diagnosticsInfo: ""
    )

    SignaturesListView(
        signatures: [signature],
        selectedSignature: .constant(signature),
        containerMimetype: .constant("application/vnd.etsi.asic-e+zip"),
        dataFilesCount: 1,
        nameUtil: Container.shared.nameUtil(),
        signatureUtil: Container.shared.signatureUtil()
    )
}
