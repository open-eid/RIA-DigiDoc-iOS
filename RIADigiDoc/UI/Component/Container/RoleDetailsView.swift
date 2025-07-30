import SwiftUI
import LibdigidocLibSwift

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
    .environmentObject(LanguageSettings())
}
