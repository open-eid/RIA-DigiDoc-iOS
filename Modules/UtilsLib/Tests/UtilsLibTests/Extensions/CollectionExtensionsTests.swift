import Foundation
import Testing
@testable import UtilsLib

class CollectionExtensionsTests {

    @Test
    func hexString_returnEmptyStringwithEmptyArray() {
        let input: [UInt8] = []
        let expectedOutput = ""

        #expect(expectedOutput == input.hexString)
    }

    @Test
    func hexString_successWithSingleByte() {
        let input: [UInt8] = [0x1F]
        let expectedOutput = "1F"

        #expect(expectedOutput == input.hexString)
    }

    @Test
    func hexString_successWithMultipleBytes() {
        let input: [UInt8] = [0x00, 0xAB, 0x3C, 0xFF]
        let expectedOutput = "00 AB 3C FF"

        #expect(expectedOutput == input.hexString)
    }
}
