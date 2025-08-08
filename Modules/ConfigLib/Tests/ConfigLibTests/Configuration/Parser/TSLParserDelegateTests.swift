import Foundation
import Testing
@testable import ConfigLib

final class TSLParserDelegateTests {
    private var parserDelegate: TSLParserDelegate!
    private var xmlParser: XMLParser!

    init() async throws {
        parserDelegate = TSLParserDelegate(sequenceNumberElement: "TSLSequenceNumber")
    }

    deinit {
        parserDelegate = nil
        xmlParser = nil
    }

    @Test
    func parser_successFindingSequenceNumber() async throws {
        let xmlString = """
        <root>
            <TSLSequenceNumber>123</TSLSequenceNumber>
        </root>
        """
        let xmlStringData = xmlString.data(using: .utf8)

        guard let data = xmlStringData else {
            Issue.record("Unable to get data from xml string")
            return
        }

        xmlParser = XMLParser(data: data)
        xmlParser.delegate = parserDelegate

        xmlParser.parse()

        #expect(123 == parserDelegate.foundSequenceNumber)
    }

    @Test
    func parser_doesNotSetFoundSequenceNumberWhenNoSequenceNumber() async throws {
        let xmlString = """
        <root>
            <otherElement>456</otherElement>
        </root>
        """
        let xmlStringData = xmlString.data(using: .utf8)

        guard let data = xmlStringData else {
            Issue.record("Unable to get data from xml string")
            return
        }

        xmlParser = XMLParser(data: data)
        xmlParser.delegate = parserDelegate

        xmlParser.parse()

        #expect(parserDelegate.foundSequenceNumber == nil)
    }

    @Test
    func parser_doesNotSetFoundSequenceNumberWhenSequenceNumberWithInvalidValue() async throws {
        let xmlString = """
        <root>
            <sequenceNumber>NotANumber</sequenceNumber>
        </root>
        """
        let xmlStringData = xmlString.data(using: .utf8)

        guard let data = xmlStringData else {
            Issue.record("Unable to get data from xml string")
            return
        }

        xmlParser = XMLParser(data: data)
        xmlParser.delegate = parserDelegate

        xmlParser.parse()

        #expect(parserDelegate.foundSequenceNumber == nil)
    }
}
