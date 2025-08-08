import Foundation
import Testing
@testable import ConfigLib

final class ConfigurationUtilTests {

    @Test
    func isSerialNewerThanCached_returnTrue() {
        let cachedSerial: Int? = nil
        let newSerial = 100
        #expect(ConfigurationUtil.isSerialNewerThanCached(cachedSerial: cachedSerial, newSerial: newSerial))
    }

    @Test
    func isSerialNewerThanCached_returnTrueWhenNewSerialIsGreater() {
        let cachedSerial: Int? = 50
        let newSerial = 100
        #expect(ConfigurationUtil.isSerialNewerThanCached(cachedSerial: cachedSerial, newSerial: newSerial))
    }

    @Test
    func isSerialNewerThanCached_returnFalseWhenNewSerialIsEqual() {
        let cachedSerial: Int? = 100
        let newSerial = 100
        #expect(!ConfigurationUtil.isSerialNewerThanCached(cachedSerial: cachedSerial, newSerial: newSerial))
    }

    @Test
    func isSerialNewerThanCached_returnFalseWhenNewSerialIsSmaller() {
        let cachedSerial: Int? = 150
        let newSerial = 100
        #expect(!ConfigurationUtil.isSerialNewerThanCached(cachedSerial: cachedSerial, newSerial: newSerial))
    }

    @Test
    func isBase64_returnTrueWhenEncodedStringIsValidBase64() {
        let validBase64 = "SGVsbG8gd29ybGQ="
        #expect(ConfigurationUtil.isBase64(encoded: validBase64))
    }

    @Test
    func isBase64_returnFalseWhenEncodedStringIsInvalidBase64() {
        let invalidBase64 = "InvalidBase64!!"
        #expect(!ConfigurationUtil.isBase64(encoded: invalidBase64))
    }

    @Test
    func isBase64_returnFalseWhenStringIsEmpty() {
        let emptyString = ""
        #expect(!ConfigurationUtil.isBase64(encoded: emptyString))
    }

    @Test
    func isBase64_returnFalseWhenStringHasPaddingIssues() {
        let improperlyPaddedBase64 = "SGVsbG8gd29ybGQ"
        #expect(!ConfigurationUtil.isBase64(encoded: improperlyPaddedBase64))
    }

    @Test
    func isBase64_returnFalseWhenStringContainsWhitespace() {
        let base64WithWhitespace = " SGVsbG8gd29ybGQ= "
        #expect(!ConfigurationUtil.isBase64(encoded: base64WithWhitespace))
    }
}
