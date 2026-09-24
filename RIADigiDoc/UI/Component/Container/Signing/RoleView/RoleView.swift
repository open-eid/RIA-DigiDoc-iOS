// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit
import CommonsLib

struct RoleView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageSettings.self) private var languageSettings

    @AppTheme private var theme
    @AppTypography private var typography

    @State private var roles: String = ""
    @State private var city: String = ""
    @State private var state: String = ""
    @State private var country: String = ""
    @State private var zipCode: String = ""

    @State private var viewModel: RoleViewModel

    let onComplete: (String, String, String, String, String) -> Void

    init(
        onComplete: @escaping (String, String, String, String, String) -> Void
    ) {
        _viewModel = State(wrappedValue: Container.shared.roleViewModel())
        self.onComplete = onComplete
    }

    private var roleTitle: String {
        languageSettings.localized("Role title")
    }

    private var cityTitle: String {
        languageSettings.localized("City title")
    }

    private var stateTitle: String {
        languageSettings.localized("State title")
    }

    private var countryTitle: String {
        languageSettings.localized("Country title")
    }

    private var zipCodeTitle: String {
        languageSettings.localized("Zip code title")
    }

    var body: some View {
        TopBarContainer(
            title: nil,
            leftIcon: "ic_m3_close_48pt_wght400",
            leftIconAccessibility: languageSettings.localized("Close"),
            onLeftClick: { dismiss() },
            showRightIcons: false,
            content: {
                ScrollView {
                    VStack(alignment: .leading, spacing: Dimensions.Padding.MPadding) {
                        Text(verbatim: languageSettings.localized("Container signing"))
                            .font(typography.headlineSmall)
                            .foregroundStyle(theme.onSurface)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, Dimensions.Padding.SPadding)
                            .accessibilityHeading(.h1)
                            .accessibilityAddTraits([.isHeader])

                        Text(verbatim: languageSettings.localized("Role and address title"))
                            .font(typography.titleMedium)
                            .foregroundStyle(theme.onSurface)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, Dimensions.Padding.SPadding)
                            .accessibilityHeading(.h2)
                            .accessibilityAddTraits([.isHeader])

                        FloatingLabelTextField(
                            title: roleTitle,
                            placeholder: roleTitle,
                            text: $roles,
                            identifier: "roles"
                        )
                        FloatingLabelTextField(
                            title: cityTitle,
                            placeholder: cityTitle,
                            text: $city,
                            identifier: "roleCity"
                        )
                        FloatingLabelTextField(
                            title: stateTitle,
                            placeholder: stateTitle,
                            text: $state,
                            identifier: "roleState"
                        )
                        FloatingLabelTextField(
                            title: countryTitle,
                            placeholder: countryTitle,
                            text: $country,
                            identifier: "roleCountry"
                        )
                        FloatingLabelTextField(
                            title: zipCodeTitle,
                            placeholder: zipCodeTitle,
                            text: $zipCode,
                            identifier: "roleZipCode"
                        )

                        PrimaryButton(
                            text: languageSettings.localized("Sign"),
                            isButtonEnabled: true,
                            action: {
                                Task {
                                    await viewModel.saveInputData(
                                        RoleData(
                                            roles: roles
                                                .split(separator: ",")
                                                .map { $0.trimmingCharacters(in: .whitespaces) },
                                            city: city,
                                            state: state,
                                            country: country,
                                            zipCode: zipCode
                                        )
                                    )
                                    onComplete(roles, city, state, country, zipCode)
                                }
                            },
                            focusedField: nil,
                            currentFocus: .constant(nil)
                        )
                        .padding(.vertical, Dimensions.Padding.MPadding)
                    }
                    .padding(.horizontal, Dimensions.Padding.SPadding)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .onAppear {
                        Task {
                            let roleData = await viewModel.getInputData()

                            await MainActor.run {
                                roles = roleData.roles.joined(separator: ", ")
                                city = roleData.city
                                state = roleData.state
                                country = roleData.country
                                zipCode = roleData.zipCode
                            }
                        }
                    }
                }
            }
        )
    }
}

#Preview {
    RoleView(
        onComplete: {_, _, _, _, _ in }
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
    .environment(NavigationPathManager())
}
