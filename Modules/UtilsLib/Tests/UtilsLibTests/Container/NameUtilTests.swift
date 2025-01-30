import Foundation
import Testing
@testable import UtilsLib

class NameUtilTests {

    @Test
    func formatName_successWithSingleComponent() {
        let input = "Firstname"
        let expectedOutput = "Firstname"
        #expect(expectedOutput == NameUtil.formatName(input))
    }

    @Test
    func formatName_successWithTwoComponents() {
        let input = "Firstname, Lastname"
        let expectedOutput = "Firstname, Lastname"
        #expect(expectedOutput == NameUtil.formatName(input))
    }

    @Test
    func formatName_successWithThreeComponents() {
        let input = "Firstname, Lastname, A123"
        let expectedOutput = "Lastname, Firstname, A123"
        #expect(expectedOutput == NameUtil.formatName(input))
    }

    @Test
    func formatName_successWithExtraSpaces() {
        let input = "  Firstname  ,  Lastname  ,  A123  "
        let expectedOutput = "Lastname, Firstname, A123"
        #expect(expectedOutput == NameUtil.formatName(input))
    }

    @Test
    func formatName_successWithSlashes() {
        let input = "Firstname/, Lastname/, A123/"
        let expectedOutput = "Lastname, Firstname, A123"
        #expect(expectedOutput == NameUtil.formatName(input))
    }

    @Test
    func formatName_successWithMultipleSpaces() {
        let input = "  Firstname,   Lastname  ,   A123  "
        let expectedOutput = "Lastname, Firstname, A123"
        #expect(expectedOutput == NameUtil.formatName(input))
    }

    @Test
    func formatName_successWithIrregularSpacing() {
        let input = "  Firstname , Lastname , A123  "
        let expectedOutput = "Lastname, Firstname, A123"
        #expect(expectedOutput == NameUtil.formatName(input))
    }

    @Test
    func formatName_successWithExtraCommas() {
        let input = ",,Firstname, , Lastname,, Jr,,"
        let expectedOutput = "Lastname, Firstname, Jr"
        #expect(expectedOutput == NameUtil.formatName(input))
    }

    @Test
    func formatName_successWithMixedFormattingIssues() {
        let input = " /Firstname/, /Lastname/, /A123/  "
        let expectedOutput = "Lastname, Firstname, A123"
        #expect(expectedOutput == NameUtil.formatName(input))
    }

    @Test
    func formatName_returnOriginalFormattedInputWithFourComponents() {
        let input = "Firstname, Lastname, A123, SomeOtherText"
        let expectedOutput = "Firstname, Lastname, A123, SomeOtherText"
        #expect(expectedOutput == NameUtil.formatName(input))
    }

    @Test
    func formatName_returnOriginalFormattedInputWithMixedFormattingIssuesOverThreeComponents() {
        let input = " /Firstname/, /Lastname/, /A123/, /SomeOtherText/  "
        let expectedOutput = "Firstname, Lastname, A123, SomeOtherText"
        #expect(expectedOutput == NameUtil.formatName(input))
    }

    @Test
    func formatName_returnEmptyStringWithEmptyStringInput() {
        let input = ""
        let expectedOutput = ""
        #expect(expectedOutput == NameUtil.formatName(input))
    }

    @Test
    func formatName_returnEmptyStringWithOnlySpacesInput() {
        let input = "     "
        let expectedOutput = ""
        #expect(expectedOutput == NameUtil.formatName(input))
    }

    @Test
    func formatName_returnEmptyStringWithOnlyCommasInput() {
        let input = ",,,, , ,"
        let expectedOutput = ""
        #expect(expectedOutput == NameUtil.formatName(input))
    }
}
