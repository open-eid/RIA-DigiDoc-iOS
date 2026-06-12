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

import CryptoObjCWrapper
import Foundation
import Testing

struct AddresseeTests {

    @Test
    func init_defaultLockLabelAndLockTypeAreEmpty() {
        let addressee = Addressee(
            data: Data(),
            cnVal: "SMITH,JOHN,38001010001",
            givenName: "JOHN",
            surname: "SMITH",
            serialNumber: nil,
            certType: .iDCardType,
            validTo: nil
        )

        #expect(addressee.lockLabel == "")
        #expect(addressee.lockType == "")
    }

    @Test
    func init_lockLabelAndLockTypeSetCorrectly() {
        let addressee = Addressee(
            data: Data(),
            cnVal: "myKey",
            givenName: nil,
            surname: nil,
            serialNumber: nil,
            certType: .passwordType,
            validTo: nil,
            concatKDFAlgorithmURI: "",
            lockLabel: "data:v=1&label=myKey&type=pw",
            lockType: "PASSWORD"
        )

        #expect(addressee.lockLabel == "data:v=1&label=myKey&type=pw")
        #expect(addressee.lockType == "PASSWORD")
        #expect(addressee.identifier == "myKey")
        #expect(addressee.certType == .passwordType)
    }

    @Test
    func init_passwordTypePreservesEmptyLockLabelAndLockType() {
        let addressee = Addressee(
            data: Data(),
            cnVal: "",
            givenName: nil,
            surname: nil,
            serialNumber: nil,
            certType: .passwordType,
            validTo: nil
        )

        #expect(addressee.lockLabel == "")
        #expect(addressee.lockType == "")
        #expect(addressee.identifier == "")
    }

    @Test
    func cnValInit_with3Segments_parsesSurnameGivenNameIdentifier() {
        let addressee = Addressee(
            cnVal: "SMITH,JOHN,38001010001",
            serialNumber: nil,
            certType: .iDCardType,
            validTo: nil,
            data: Data()
        )

        #expect(addressee.surname == "SMITH")
        #expect(addressee.givenName == "JOHN")
        #expect(addressee.identifier == "38001010001")
    }

    @Test
    func cnValInit_withMoreThan3Segments_usesFirst3() {
        let addressee = Addressee(
            cnVal: "SMITH,JOHN,38001010001,EXTRA",
            serialNumber: nil,
            certType: .iDCardType,
            validTo: nil,
            data: Data()
        )

        #expect(addressee.surname == "SMITH")
        #expect(addressee.givenName == "JOHN")
        #expect(addressee.identifier == "38001010001")
    }

    @Test
    func cnValInit_with2Segments_doesNotSplitAndUsesFullStringAsIdentifier() {
        let addressee = Addressee(
            cnVal: "ACME OÜ,12345678",
            serialNumber: nil,
            certType: .eSealType,
            validTo: nil,
            data: Data()
        )

        #expect(addressee.surname == nil)
        #expect(addressee.givenName == nil)
        #expect(addressee.identifier == "ACME OÜ,12345678")
    }

    @Test
    func cnValInit_with1Segment_usesFullStringAsIdentifier() {
        let addressee = Addressee(
            cnVal: "SomeCompany",
            serialNumber: nil,
            certType: .eSealType,
            validTo: nil,
            data: Data()
        )

        #expect(addressee.surname == nil)
        #expect(addressee.givenName == nil)
        #expect(addressee.identifier == "SomeCompany")
    }

    @Test
    func cnValInit_withEmptyString_usesEmptyIdentifier() {
        let addressee = Addressee(
            cnVal: "",
            serialNumber: nil,
            certType: .unknownType,
            validTo: nil,
            data: Data()
        )

        #expect(addressee.surname == nil)
        #expect(addressee.givenName == nil)
        #expect(addressee.identifier == "")
    }

    @Test
    func dataConvenienceInit_setsIdentifierToCnVal() {
        let addressee = Addressee(data: Data([1, 2, 3]), cnVal: "TestLabel")

        #expect(addressee.identifier == "TestLabel")
        #expect(addressee.certType == .unknownType)
        #expect(addressee.lockLabel == "")
        #expect(addressee.lockType == "")
    }

    @Test
    func cnValInit_lockLabelAndLockTypeSetCorrectly() {
        let addressee = Addressee(
            cnVal: "SMITH,JOHN,38001010001",
            serialNumber: nil,
            certType: .iDCardType,
            validTo: nil,
            data: Data(),
            lockLabel: "rawLockLabel",
            lockType: "PUBLIC_KEY"
        )

        #expect(addressee.lockLabel == "rawLockLabel")
        #expect(addressee.lockType == "PUBLIC_KEY")
    }

    @Test
    func cnValInit_defaultLockLabelAndLockTypeAreEmpty() {
        let addressee = Addressee(
            cnVal: "SMITH,JOHN,38001010001",
            serialNumber: nil,
            certType: .iDCardType,
            validTo: nil,
            data: Data()
        )

        #expect(addressee.lockLabel == "")
        #expect(addressee.lockType == "")
    }
}
