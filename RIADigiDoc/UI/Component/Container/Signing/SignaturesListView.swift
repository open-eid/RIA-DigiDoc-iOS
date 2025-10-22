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
import UtilsLib

struct SignaturesListView: View {
    @AppTheme private var theme
    @AppTypography private var typography

    let signatures: [SignatureWrapper]
    let timestamps: [SignatureWrapper]
    @Binding var selectedSignature: SignatureWrapper?
    @Binding var containerMimetype: String
    var dataFilesCount: Int
    var showRemoveSignatureButton: Bool
    @Binding var showRemoveSignatureModal: Bool

    let nameUtil: NameUtilProtocol
    let signatureUtil: SignatureUtilProtocol

    var body: some View {
        LazyVStack {
            if #available(iOS 26.0, *) {
                ForEach(timestamps.enumerated(), id: \.offset) { index, timestamp in
                    SignatureView(
                        signatureIndex: index + 1,
                        containerMimetype: containerMimetype,
                        dataFilesCount: dataFilesCount,
                        signature: timestamp,
                        isTimestamp: true,
                        nameUtil: nameUtil,
                        signatureUtil: signatureUtil,
                        showRemoveSignatureButton: showRemoveSignatureButton,
                        showRemoveSignatureModal: $showRemoveSignatureModal,
                        onSelect: {
                            selectedSignature = timestamp
                        }
                    )
                }
            } else {
                ForEach(Array(timestamps.enumerated()), id: \.offset) { index, timestamp in
                    SignatureView(
                        signatureIndex: index + 1,
                        containerMimetype: containerMimetype,
                        dataFilesCount: dataFilesCount,
                        signature: timestamp,
                        isTimestamp: true,
                        nameUtil: nameUtil,
                        signatureUtil: signatureUtil,
                        showRemoveSignatureButton: showRemoveSignatureButton,
                        showRemoveSignatureModal: $showRemoveSignatureModal,
                        onSelect: {
                            selectedSignature = timestamp
                        }
                    )
                }
            }
            if #available(iOS 26.0, *) {
                ForEach(signatures.enumerated(), id: \.offset) { index, signature in
                    SignatureView(
                        signatureIndex: index + 1,
                        containerMimetype: containerMimetype,
                        dataFilesCount: dataFilesCount,
                        signature: signature,
                        nameUtil: nameUtil,
                        signatureUtil: signatureUtil,
                        showRemoveSignatureButton: showRemoveSignatureButton,
                        showRemoveSignatureModal: $showRemoveSignatureModal,
                        onSelect: {
                            selectedSignature = signature
                        }
                    )
                }
            } else {
                ForEach(Array(signatures.enumerated()), id: \.offset) { index, signature in
                    SignatureView(
                        signatureIndex: index + 1,
                        containerMimetype: containerMimetype,
                        dataFilesCount: dataFilesCount,
                        signature: signature,
                        nameUtil: nameUtil,
                        signatureUtil: signatureUtil,
                        showRemoveSignatureButton: showRemoveSignatureButton,
                        showRemoveSignatureModal: $showRemoveSignatureModal,
                        onSelect: {
                            selectedSignature = signature
                        }
                    )
                }

            }
        }
    }
}

#Preview {
    let signature = SignatureWrapper(
        pos: 0,
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
        roles: ["Role 1", "Role 2"],
        city: "Test City",
        state: "Test State",
        country: "Test Country",
        zipCode: "Test12345",
        format: "BES/time-stamp",
        messageImprint: Data(),
        diagnosticsInfo: ""
    )

    SignaturesListView(
        signatures: [signature],
        timestamps: [signature],
        selectedSignature: .constant(signature),
        containerMimetype: .constant("application/vnd.etsi.asic-e+zip"),
        dataFilesCount: 1,
        showRemoveSignatureButton: true,
        showRemoveSignatureModal: .constant(false),
        nameUtil: Container.shared.nameUtil(),
        signatureUtil: Container.shared.signatureUtil()
    )
    .environmentObject(Container.shared.languageSettings())
    .environmentObject(Container.shared.themeSettings())
}
