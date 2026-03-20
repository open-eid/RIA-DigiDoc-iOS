/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
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

struct MyEidDataView: View {
    @Environment(LanguageSettings.self) private var languageSettings

    private let givenName: String
    private let surname: String
    private let citizenship: String
    private let personalCode: String
    private let dateOfBirth: String
    private let idCardNumber: String
    private let dateOfExpiry: String
    private let documentExpirationStatus: MyEidDocumentStatus

    init(
        givenName: String,
        surname: String,
        citizenship: String,
        personalCode: String,
        dateOfBirth: String,
        idCardNumber: String,
        dateOfExpiry: String,
        documentExpirationStatus: MyEidDocumentStatus
    ) {
        self.givenName = givenName
        self.surname = surname
        self.citizenship = citizenship
        self.personalCode = personalCode
        self.dateOfBirth = dateOfBirth
        self.idCardNumber = idCardNumber
        self.dateOfExpiry = dateOfExpiry
        self.documentExpirationStatus = documentExpirationStatus
    }

    var body: some View {
        MyEidDetailView(
            myEidDataItem: MyEidDataItem(
                title: languageSettings.localized("Given names"),
                value: givenName
            )
        )
        MyEidDetailView(
            myEidDataItem: MyEidDataItem(
                title: languageSettings.localized("Surname"),
                value: surname
            )
        )
        MyEidDetailView(
            myEidDataItem: MyEidDataItem(
                title: languageSettings.localized("Citizenship"),
                value: citizenship
            )
        )
        MyEidDetailView(
            myEidDataItem: MyEidDataItem(
                title: languageSettings.localized("Personal code"),
                value: personalCode,
                spellOutCharacters: true
            )
        )
        MyEidDetailView(
            myEidDataItem: MyEidDataItem(
                title: languageSettings.localized("Date of birth"),
                value: dateOfBirth
            )
        )
        MyEidDetailView(
            myEidDataItem: MyEidDataItem(
                title: languageSettings.localized("Id card number"),
                value: idCardNumber,
                spellOutCharacters: true
            )
        )
        MyEidDetailView(
            myEidDataItem: MyEidDataItem(
                title: languageSettings.localized("Valid to date"),
                value: dateOfExpiry,
                status: documentExpirationStatus
            )
        )
    }
}

#Preview {
    MyEidDataView(
        givenName: "Given name",
        surname: "Surname",
        citizenship: "EST",
        personalCode: "12345678901",
        dateOfBirth: Date().formatted(),
        idCardNumber: "A1234567890",
        dateOfExpiry: Date().formatted(),
        documentExpirationStatus: .valid
    )
}
