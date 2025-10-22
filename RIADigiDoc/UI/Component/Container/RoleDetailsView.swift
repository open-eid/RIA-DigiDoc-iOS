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

import FactoryKit
import LibdigidocLibSwift
import SwiftUI

struct RoleDetailsView: View {
    @AppTheme private var theme
    @AppTypography private var typography

    @EnvironmentObject private var languageSettings: LanguageSettings

    let signature: SignatureWrapper

    var roles: String {
        return signature.roles.joined(separator: ", ")
    }

    var city: String {
        return signature.city
    }

    var state: String {
        return signature.state
    }

    var country: String {
        return signature.country
    }

    var zipCode: String {
        return signature.zipCode
    }

    var body: some View {
        SignerDetailView(
            signatureDataItem: SignatureDataItem(
                title: languageSettings.localized("Role title"),
                value: roles
            )
        )

        SignerDetailView(
            signatureDataItem: SignatureDataItem(
                title: languageSettings.localized("City title"),
                value: city
            )
        )

        SignerDetailView(
            signatureDataItem: SignatureDataItem(
                title: languageSettings.localized("State title"),
                value: state
            )
        )

        SignerDetailView(
            signatureDataItem: SignatureDataItem(
                title: languageSettings.localized("Country title"),
                value: country
            )
        )

        SignerDetailView(
            signatureDataItem: SignatureDataItem(
                title: languageSettings.localized("Zip code title"),
                value: zipCode
            )
        )
    }

}

#Preview {
    RoleDetailsView(
        signature: SignatureWrapper(
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
    )
    .environmentObject(Container.shared.languageSettings())
    .environmentObject(Container.shared.themeSettings())
}
