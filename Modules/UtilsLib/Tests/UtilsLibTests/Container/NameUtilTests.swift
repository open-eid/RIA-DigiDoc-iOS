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

import Foundation
import Testing
@testable import UtilsLib

class NameUtilTests {

    private let nameUtil: NameUtil

    init() async throws {
        nameUtil = NameUtil()
    }

    @Test
    func formatName_successWithSingleComponent() async {
        let input = "Firstname"
        let expectedOutput = "Firstname"
        #expect(expectedOutput == nameUtil.formatName(input))
    }

    @Test
    func formatName_successWithTwoComponents() async {
        let input = "Firstname, Lastname"
        let expectedOutput = "Firstname, Lastname"
        #expect(expectedOutput == nameUtil.formatName(input))
    }

    @Test
    func formatName_successWithThreeComponents() async {
        let input = "Lastname, Firstname, A123"
        let expectedOutput = "Firstname Lastname, A123"
        #expect(expectedOutput == nameUtil.formatName(input))
    }

    @Test
    func formatName_successWithExtraSpaces() async {
        let input = "  Firstname  ,  Lastname  ,  A123  "
        let expectedOutput = "Lastname Firstname, A123"
        #expect(expectedOutput == nameUtil.formatName(input))
    }

    @Test
    func formatName_successWithSlashes() async {
        let input = "Firstname/, Lastname/, A123/"
        let expectedOutput = "Lastname Firstname, A123"
        #expect(expectedOutput == nameUtil.formatName(input))
    }

    @Test
    func formatName_successWithMultipleSpaces() async {
        let input = "  Firstname,   Lastname  ,   A123  "
        let expectedOutput = "Lastname Firstname, A123"
        #expect(expectedOutput == nameUtil.formatName(input))
    }

    @Test
    func formatName_successWithIrregularSpacing() async {
        let input = "  Firstname , Lastname , A123  "
        let expectedOutput = "Lastname Firstname, A123"
        #expect(expectedOutput == nameUtil.formatName(input))
    }

    @Test
    func formatName_successWithExtraCommas() async {
        let input = ",,Firstname, , Lastname,, Jr,,"
        let expectedOutput = "Lastname Firstname, Jr"
        #expect(expectedOutput == nameUtil.formatName(input))
    }

    @Test
    func formatName_successWithMixedFormattingIssues() async {
        let input = " /Firstname/, /Lastname/, /A123/  "
        let expectedOutput = "Lastname Firstname, A123"
        #expect(expectedOutput == nameUtil.formatName(input))
    }

    @Test
    func formatName_returnOriginalFormattedInputWithFourComponents() async {
        let input = "Firstname, Lastname, A123, SomeOtherText"
        let expectedOutput = "Firstname, Lastname, A123, Someothertext"
        #expect(expectedOutput == nameUtil.formatName(input))
    }

    @Test
    func formatName_returnOriginalFormattedInputWithMixedFormattingIssuesOverThreeComponents() async {
        let input = " /Firstname/, /Lastname/, /A123/, /SomeOtherText/  "
        let expectedOutput = "Firstname, Lastname, A123, Someothertext"
        #expect(expectedOutput == nameUtil.formatName(input))
    }

    @Test
    func formatName_returnEmptyStringWithEmptyStringInput() async {
        let input = ""
        let expectedOutput = ""
        #expect(expectedOutput == nameUtil.formatName(input))
    }

    @Test
    func formatName_returnEmptyStringWithOnlySpacesInput() async {
        let input = "     "
        let expectedOutput = ""
        #expect(expectedOutput == nameUtil.formatName(input))
    }

    @Test
    func formatName_returnEmptyStringWithOnlyCommasInput() async {
        let input = ",,,, , ,"
        let expectedOutput = ""
        #expect(expectedOutput == nameUtil.formatName(input))
    }
}
