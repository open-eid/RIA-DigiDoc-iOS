import SwiftUI
import FactoryKit
import LibdigidocLibSwift
import CommonsLib
import UtilsLib

struct SignatureView: View {
    @AppTheme private var theme
    @AppTypography private var typography
    @EnvironmentObject private var languageSettings: LanguageSettings

    let containerMimetype: String
    let dataFilesCount: Int

    let signature: SignatureWrapper
    let nameUtil: NameUtilProtocol
    let signatureUtil: SignatureUtilProtocol

    @State private var showDetail = false
    @State private var showBottomSheetFromButton = false
    @State private var showBottomSheetFromTap = false
    @State private var isVoiceOverRunning = UIAccessibility.isVoiceOverRunning

    private var bottomSheetActions: [BottomSheetButton] {
        [
            BottomSheetButton(
                icon: "ic_m3_edit_48pt_wght400",
                title: languageSettings.localized("Signature details"),
                accessibilityLabel: languageSettings.localized("Signature details").lowercased(),
                onClick: {
                    showDetail = true
                }
            ),
            BottomSheetButton(
                icon: "ic_m3_encrypted_48pt_wght400",
                title: languageSettings.localized("Remove signature"),
                accessibilityLabel: languageSettings.localized("Remove signature").lowercased(),
                onClick: {
                    // TODO: Implement remove signature action
                }
            )
        ]
    }

    var body: some View {
        let signedDate = DateUtil.getFormattedDateTime(
            dateTimeString: signature.trustedSigningTime,
            isUTC: false
        )

        VStack {
            HStack {
                Image("ic_m3_stylus_note_48pt_wght400")
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                    .foregroundStyle(theme.onSurface)
                    .padding(.trailing, Dimensions.Padding.SPadding)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: Dimensions.Padding.XXSPadding) {
                    StyledNameText(name: nameUtil.formatName(signature.signedBy))
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)

                    Text(
                        String(
                            format: languageSettings.localized("Signed %@ at %@"),
                            signedDate.date,
                            signedDate.time
                        )
                    )
                    .font(typography.bodyMedium)
                    .foregroundStyle(theme.onSurfaceVariant)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)

                    ColoredSignedStatusText(
                        text: signatureUtil.getSignatureStatusText(status: signature.status),
                        status: signature.status
                    )
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                }

                Spacer()

                Button(action: {
                    showBottomSheetFromButton = true
                }, label: {
                    Image("ic_m3_more_vert_48pt_wght400")
                        .resizable()
                        .scaledToFit()
                        .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                        .foregroundStyle(theme.onBackground)
                        .accessibilityLabel(languageSettings.localized("More options"))
                })
                .bottomSheet(isPresented: $showBottomSheetFromButton, actions: bottomSheetActions)
            }
            .padding(Dimensions.Padding.MSPadding)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if !isVoiceOverRunning {
                showBottomSheetFromTap = true
            }
        }
        .onAppear {
            NotificationCenter.default.addObserver(
                forName: UIAccessibility.voiceOverStatusDidChangeNotification,
                object: nil,
                queue: .main
            ) { _ in
                Task { @MainActor in
                    isVoiceOverRunning = UIAccessibility.isVoiceOverRunning
                }
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self,
                name: UIAccessibility.voiceOverStatusDidChangeNotification,
                object: nil)
        }
        .background(
            NavigationLink(
                destination: SignatureDetailView(
                    signature: signature,
                    containerMimetype: containerMimetype,
                    dataFilesCount: dataFilesCount
                ),
                isActive: $showDetail
            ) {
                EmptyView()
            }
            .hidden()
        )
        .listRowInsets(EdgeInsets())
        .accessibilityAddTraits([.isButton])
        .bottomSheet(isPresented: $showBottomSheetFromTap, actions: bottomSheetActions)
    }
}

#Preview {
    SignatureView(
        containerMimetype: Constants.MimeType.Asice,
        dataFilesCount: 1,
        signature: SignatureWrapper(
            signingCert: Data(),
            timestampCert: Data(),
            ocspCert: Data(),
            signatureId: "",
            claimedSigningTime: "",
            signatureMethod: "",
            ocspProducedAt: "",
            timeStampTime: "",
            signedBy: "Signer 1",
            trustedSigningTime: Date.now.formatted(),
            format: "",
            messageImprint: Data(),
            diagnosticsInfo: ""
        ),
        nameUtil: Container.shared.nameUtil(),
        signatureUtil: Container.shared.signatureUtil()
    )
}
