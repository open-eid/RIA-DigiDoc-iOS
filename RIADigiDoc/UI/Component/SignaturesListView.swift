import SwiftUI
import LibdigidocLibSwift

struct SignaturesListView: View {
    let signatures: [SignatureWrapper]
    @Binding var selectedSignature: SignatureWrapper?
    @Binding var containerMimetype: String
    var dataFilesCount: Int

    var body: some View {
        List(signatures, id: \.self) { signature in
            VStack(alignment: .leading) {
                Text(verbatim: signature.signedBy)
                Text(verbatim: signature.status.rawValue)
                Text(verbatim: signature.trustedSigningTime)
            }
            .accessibilityAddTraits(.isButton)
            .contentShape(Rectangle())
            .onTapGesture {
                selectedSignature = signature
            }
        }
        .background(
            Group {
                if let selectedSignature = selectedSignature {
                    NavigationLink(
                        destination: SignatureDetailView(
                            signature: selectedSignature,
                            containerMimetype: containerMimetype,
                            dataFilesCount: dataFilesCount
                        ),
                        isActive: Binding(
                            get: { self.selectedSignature != nil },
                            set: { if !$0 { self.selectedSignature = nil } }
                        )
                    ) {}
                    .hidden()
                }
            }
        )
    }
}
