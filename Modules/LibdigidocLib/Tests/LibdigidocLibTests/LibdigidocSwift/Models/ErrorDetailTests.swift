import Foundation
import Testing

@testable import LibdigidocLibSwift

final class ErrorDetailsTests {

    @Test
    func defaultInitializer_success() {
        let errorDetail = ErrorDetail()

        #expect(errorDetail.message.isEmpty)
        #expect(errorDetail.code == 0)
        #expect(errorDetail.userInfo.isEmpty)
    }

    @Test
    func detailsInitializer_success() {
        let message = "Test error message"
        let code = 100
        let userInfo: [String: String] = ["key": "value"]

        let errorDetail = ErrorDetail(message: message, code: code, userInfo: userInfo)

        #expect(message == errorDetail.message)
        #expect(code == errorDetail.code)
        #expect(userInfo == errorDetail.userInfo)
    }

    @Test
    func nsErrorInitializer_success() {
        let userInfo: [String: Any] = [
            NSLocalizedDescriptionKey: "Test NSError message",
            "key": "value"
        ]
        let nsError = NSError(domain: "TestDomain", code: 123, userInfo: userInfo)

        let errorDetail = ErrorDetail(nsError: nsError)

        #expect(nsError.localizedDescription == errorDetail.message)
        #expect(nsError.code == errorDetail.code)
        #expect(errorDetail.userInfo == ["key": "value", NSLocalizedDescriptionKey: "Test NSError message"])
    }

    @Test
    func nsErrorInitializer_successWithExtraInfo() {
        let userInfo: [String: Any] = [
            NSLocalizedDescriptionKey: "Test NSError message",
            "key": "value"
        ]
        let extraInfo: [String: String] = ["extraKey": "extraValue"]
        let nsError = NSError(domain: "TestDomain", code: 123, userInfo: userInfo)

        let errorDetail = ErrorDetail(nsError: nsError, extraInfo: extraInfo)

        #expect(nsError.localizedDescription == errorDetail.message)
        #expect(nsError.code == errorDetail.code)
        #expect(errorDetail.userInfo == [
            "key": "value",
            NSLocalizedDescriptionKey: "Test NSError message",
            "extraKey": "extraValue"
        ])
    }

    @Test
    func errorDetailDescription_success() {
        let message = "Test description message"
        let code = 123
        let userInfo: [String: String] = ["key": "value"]
        let errorDetail = ErrorDetail(message: message, code: code, userInfo: userInfo)

        let description = errorDetail.description

        #expect(description.contains("Error: \(message)"))
        #expect(description.contains("Code: \(code)"))
        #expect(description.contains("Info: \(userInfo)"))
    }
}
