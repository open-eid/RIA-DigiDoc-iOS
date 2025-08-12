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
    let showSignedDate: Bool
    let showMoreOptionsButton: Bool
    let showRole: Bool

    @State private var showDetail = false
    @State private var showBottomSheetFromButton = false
    @State private var showBottomSheetFromTap = false
    @State private var isVoiceOverRunning = UIAccessibility.isVoiceOverRunning

    private var bottomSheetActions: [BottomSheetButton] {
        SignatureBottomSheetActions.actions(
            languageSettings: languageSettings,
            onDetailsButtonClick: {
                showDetail = true
            }
        )
    }

    init(
        containerMimetype: String,
        dataFilesCount: Int,
        signature: SignatureWrapper,
        nameUtil: NameUtilProtocol = Container.shared.nameUtil(),
        signatureUtil: SignatureUtilProtocol = Container.shared.signatureUtil(),
        showSignedDate: Bool = true,
        showMoreOptionsButton: Bool = true,
        showRole: Bool = true
    ) {
        self.containerMimetype = containerMimetype
        self.dataFilesCount = dataFilesCount
        self.signature = signature
        self.nameUtil = nameUtil
        self.signatureUtil = signatureUtil
        self.showSignedDate = showSignedDate
        self.showMoreOptionsButton = showMoreOptionsButton
        self.showRole = showRole
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

                    if showSignedDate {
                        Text(verbatim:
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
                    }

                    ColoredSignedStatusText(
                        text: signatureUtil.getSignatureStatusText(status: signature.status),
                        status: signature.status
                    )
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)

                    if showRole && !signature.roles.isEmpty {
                        Text(verbatim: signature.roles.joined(separator: " / "))
                            .font(typography.bodyMedium)
                            .foregroundStyle(theme.onSurface)
                            .lineLimit(2)
                            .truncationMode(.tail)
                    }
                }

                Spacer()

                if showMoreOptionsButton {
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
            roles: ["Role 1", "Role 2"],
            city: "Test City",
            state: "Test State",
            country: "Test Country",
            zipCode: "Test12345",
            format: "",
            messageImprint: Data(),
            diagnosticsInfo: ""
        ),
        nameUtil: Container.shared.nameUtil(),
        signatureUtil: Container.shared.signatureUtil()
    )
    .environmentObject(LanguageSettings())
}
