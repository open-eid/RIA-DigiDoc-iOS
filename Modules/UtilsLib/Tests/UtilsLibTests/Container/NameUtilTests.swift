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
