import Foundation
import Testing
@testable import UtilsLib

class TextUtilTests {

    @Test
    func removeSlashes_successWithSingleBackslash() {
        let input = "Test\\Data"
        let expectedOutput = "TestData"

        #expect(expectedOutput == TextUtil.removeSlashes(input))
    }

    @Test
    func removeSlashes_successWithMultipleBackslashes() {
        let input = "Text\\With\\Slashes"
        let expectedOutput = "TextWithSlashes"

        #expect(expectedOutput == TextUtil.removeSlashes(input))
    }

    @Test
    func removeSlashes_successWithNoBackslashes() {
        let input = "WithoutBackslashes"
        let expectedOutput = "WithoutBackslashes"

        #expect(expectedOutput == TextUtil.removeSlashes(input))
    }

    @Test
    func removeSlashes_returnEmptyStringWithEmptyStringInput() {
        let input = ""
        let expectedOutput = ""

        #expect(expectedOutput == TextUtil.removeSlashes(input))
    }

    @Test
    func removeSlashes_returnEmptyStringWithOnlyBackslashesInput() {
        let input = "\\\\\\"
        let expectedOutput = ""

        #expect(expectedOutput == TextUtil.removeSlashes(input))
    }

    @Test
    func formatSerialNumber_successWithColons() {
        let input = "AA:BB:CC:DD:EE"
        let expectedOutput = "AA BB CC DD EE"

        #expect(expectedOutput == TextUtil.formatSerialNumber(input))
    }

    @Test
    func formatSerialNumber_successWithLowercaseLettersAndColons() {
        let input = "aa:bb:cc:dd:ee"
        let expectedOutput = "AA BB CC DD EE"

        #expect(expectedOutput == TextUtil.formatSerialNumber(input))
    }

    @Test
    func formatSerialNumber_successWithoutColons() {
        let input = "AABBCCDDEE"
        let expectedOutput = "AABBCCDDEE"

        #expect(expectedOutput == TextUtil.formatSerialNumber(input))
    }

    @Test
    func formatSerialNumber_successWithMixedColonsAndSpaces() {
        let input = "AA:BB CC:DD"
        let expectedOutput = "AA BB CC DD"

        #expect(expectedOutput == TextUtil.formatSerialNumber(input))
    }

    @Test
    func formatSerialNumber_returnEmptyStringWithEmptyStringInput() {
        let input = ""
        let expectedOutput = ""

        #expect(expectedOutput == TextUtil.formatSerialNumber(input))
    }
}
