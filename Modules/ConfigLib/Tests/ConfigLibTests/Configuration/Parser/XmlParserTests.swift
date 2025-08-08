import Foundation
import Testing
@testable import ConfigLib

struct XmlParserTests {
    private let xmlParser: XmlParser!

    init() async throws {
        xmlParser = XmlParser()
    }

    @Test
    func readSequenceNumber_returnSequenceNumberWhenValidXml() async throws {
        let validXml = """
        <root>
            <TSLSequenceNumber>123</TSLSequenceNumber>
        </root>
        """
        let validXmlData = validXml.data(using: .utf8)

        guard let data = validXmlData else {
            Issue.record("Unable to get data from xml string")
            return
        }

        let mockInputStream = InputStream(data: data)

        let result = try xmlParser.readSequenceNumber(from: mockInputStream)

        #expect(123 == result)
    }

    @Test
    func readSequenceNumber_throwErrorWhenNoSequenceNumber() async throws {
        let noSequenceNumberXml = """
        <root>
            <OtherElement>456</OtherElement>
        </root>
        """
        let noSequenceNumberXmlData = noSequenceNumberXml.data(using: .utf8)

        guard let data = noSequenceNumberXmlData else {
            Issue.record("Unable to get data from xml string")
            return
        }

        let mockInputStream = InputStream(data: data)

        #expect(throws: TSLParserError.errorReadingVersion) {
            _ = try xmlParser.readSequenceNumber(from: mockInputStream)
        }
    }

    @Test
    func readSequenceNumber_throwErrorWhenInvalidXml() async throws {
        let invalidXml = """
        <root>
            <TSLSequenceNumber>123
        """
        let invalidXmlData = invalidXml.data(using: .utf8)

        guard let data = invalidXmlData else {
            Issue.record("Unable to get data from xml string")
            return
        }

        let mockInputStream = InputStream(data: data)

        #expect(throws: TSLParserError.errorReadingVersion) {
            _ = try xmlParser.readSequenceNumber(from: mockInputStream)
        }
    }

    @Test
    func readSequenceNumber_throwErrorWhenSequenceNumberIsInvalid() async throws {
        let invalidSequenceNumberXml = """
        <root>
            <TSLSequenceNumber>InvalidNumber</TSLSequenceNumber>
        </root>
        """
        let invalidSequenceNumberXmlData = invalidSequenceNumberXml.data(using: .utf8)

        guard let data = invalidSequenceNumberXmlData else {
            Issue.record("Unable to get data from xml string")
            return
        }

        let mockInputStream = InputStream(data: data)

        #expect(throws: TSLParserError.errorReadingVersion) {
            _ = try xmlParser.readSequenceNumber(from: mockInputStream)
        }
    }
}
