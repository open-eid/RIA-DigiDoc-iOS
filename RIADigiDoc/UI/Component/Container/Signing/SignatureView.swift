/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
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

import SwiftUI
import FactoryKit
import LibdigidocLibSwift
import CommonsLib
import UtilsLib

struct SignatureView: View {
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @Environment(LanguageSettings.self) private var languageSettings
    @AppTheme private var theme
    @AppTypography private var typography

    @Environment(NavigationPathManager.self) private var pathManager

    @AccessibilityFocusState private var focusedField: AccessibilityField?

    let signatureIndex: Int

    let containerMimetype: String
    let dataFilesCount: Int

    let signature: SignatureWrapper
    let isTimestamp: Bool
    let nameUtil: NameUtilProtocol
    let signatureUtil: SignatureUtilProtocol
    let showSignedDate: Bool
    let showMoreOptionsButton: Bool
    let showRole: Bool
    var showRemoveSignatureButton: Bool
    @Binding var showRemoveSignatureModal: Bool
    var onSelect: (() -> Void)?

    @State private var showDetail = false
    @State private var showBottomSheetFromButton = false
    @State private var isVoiceOverObserverAdded = false
    @State private var isVoiceOverRunning = UIAccessibility.isVoiceOverRunning

    private var bottomSheetActions: [BottomSheetButton] {
        SignatureBottomSheetActions.actions(
            showRemoveSignatureButton: showRemoveSignatureButton,
            onDetailsButtonClick: {
                pathManager
                    .navigate(
                        to: .signatureDetailView(
                            signature: signature,
                            isTimestamp: isTimestamp,
                            containerMimetype: containerMimetype,
                            dataFilesCount: dataFilesCount
                        )
                    )

            },
            onRemoveSignatureButtonClick: {
                onSelect?()
                showRemoveSignatureModal = true
            }
        )
    }

    init(
        signatureIndex: Int,
        containerMimetype: String,
        dataFilesCount: Int,
        signature: SignatureWrapper,
        isTimestamp: Bool = false,
        nameUtil: NameUtilProtocol = Container.shared.nameUtil(),
        signatureUtil: SignatureUtilProtocol = Container.shared.signatureUtil(),
        showSignedDate: Bool = true,
        showMoreOptionsButton: Bool = true,
        showRole: Bool = true,
        showRemoveSignatureButton: Bool = true,
        showRemoveSignatureModal: Binding<Bool>,
        onSelect: (() -> Void)? = nil
    ) {
        self.signatureIndex = signatureIndex
        self.containerMimetype = containerMimetype
        self.dataFilesCount = dataFilesCount
        self.signature = signature
        self.isTimestamp = isTimestamp
        self.nameUtil = nameUtil
        self.signatureUtil = signatureUtil
        self.showSignedDate = showSignedDate
        self.showMoreOptionsButton = showMoreOptionsButton
        self.showRole = showRole
        self.showRemoveSignatureButton = showRemoveSignatureButton
        self._showRemoveSignatureModal = showRemoveSignatureModal
        self.onSelect = onSelect
    }

    var body: some View {
        let signedDate = DateUtil.getFormattedDateTime(
            dateTimeString: signature.trustedSigningTime,
            isUTC: false
        )
        VStack {
            HStack {
                Image(isTimestamp ? "ic_m3_approval_48dp_wght400" : "ic_m3_stylus_note_48pt_wght400")
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                    .foregroundStyle(theme.onSurface)
                    .padding(.trailing, Dimensions.Padding.SPadding)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: Dimensions.Padding.XXSPadding) {
                    let signedBy = nameUtil.formatName(signature.signedBy)
                    StyledNameText(name: signedBy, allCaps: isTimestamp)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                        .accessibilityLabel(
                            signatureIndex != 0 ?
                            Text(
                                verbatim: "\(languageSettings.localized(isTimestamp ? "Timestamp" : "Signature")) " +
                                "\(signatureIndex), \(signedBy.lowercased())"
                            ) :
                                Text(verbatim: signedBy.lowercased())
                        )

                    if showSignedDate {
                        Text(verbatim: languageSettings.localized("Signed at", [signedDate.date, signedDate.time]))
                            .font(typography.bodyMedium)
                            .foregroundStyle(theme.onSurfaceVariant)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                    }

                    ColoredSignedStatusText(
                        text: languageSettings.localized(
                            signatureUtil.getSignatureStatusText(status: signature.status)
                        ),
                        status: signature.status
                    )
                    .multilineTextAlignment(.center)

                    if showRole && !signature.roles.isEmpty {
                        Text(verbatim: signature.roles.joined(separator: " / "))
                            .font(typography.bodyMedium)
                            .foregroundStyle(theme.onSurface)
                            .lineLimit(2)
                            .truncationMode(.tail)
                    }
                }
                .accessibilityElement(children: .combine)

                Spacer()

                if showMoreOptionsButton {
                    Button(action: accessibleAction(
                        voiceOverEnabled: voiceOverEnabled,
                        focusedField: $focusedField,
                        action: {
                            showBottomSheetFromButton = true
                        }
                    ), label: {
                        Image("ic_m3_more_vert_48pt_wght400")
                            .resizable()
                            .scaledToFit()
                            .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                            .foregroundStyle(theme.onBackground)
                            .accessibilityLabel(
                                Text(verbatim:
                                        "\(languageSettings.localized(isTimestamp ? "Timestamp" : "Signature")) " +
                                     "\(signatureIndex), \(languageSettings.localized("More options"))"
                                    )
                            )
                    })
                    .bottomSheet(isPresented: $showBottomSheetFromButton, actions: bottomSheetActions)
                    .accessibilityFocusRestore(
                        focusedField: $focusedField,
                        field: .signature(.openSignatureOptionsButton),
                        when: showBottomSheetFromButton
                    )
                }
            }
            .padding(Dimensions.Padding.MSPadding)
        }
        .contentShape(Rectangle())
        .listRowInsets(EdgeInsets())
    }

}

#Preview {
    SignatureView(
        signatureIndex: 1,
        containerMimetype: Constants.MimeType.Asice,
        dataFilesCount: 1,
        signature: SignatureWrapper(
            pos: 0,
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
        signatureUtil: Container.shared.signatureUtil(),
        showRemoveSignatureModal: .constant(false)
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
