import Foundation
import Testing
import CryptoKit
@testable import UtilsLib

class DigestExtensionsTests {

    @Test
    func hexString_suceessWithSHA256DigestAndDefaultSeparator() {
        let input = Data("Test Data!".utf8)

        let digest = SHA256.hash(data: input)

        let expectedOutput = digest.map { String(format: "%02X", $0) }.joined(separator: " ")

        #expect(expectedOutput == digest.hexString())
    }

    @Test
    func hexString_successWithSHA256DigestAndCustomSeparator() {
        let input = Data("Test Data!".utf8)

        let digest = SHA256.hash(data: input)

        let expectedOutput = digest.map { String(format: "%02X", $0) }.joined(separator: "-")

        #expect(expectedOutput == digest.hexString(separator: "-"))
    }

    @Test
    func hexString_successWithSHA256DigestEmptyStringSeparator() {
        let input = Data("Test Data!".utf8)

        let digest = SHA256.hash(data: input)

        let expectedOutput = digest.map { String(format: "%02X", $0) }.joined(separator: "")

        #expect(expectedOutput == digest.hexString(separator: ""))
    }
}
