import Foundation
import Testing

@testable import LibdigidocLibSwift

final class DigiDocErrorTests {

    @Test
    func errorDetail_successWithInitializationFailedError() {
        let errorDetail = ErrorDetail(message: "Initialization failed", code: 123, userInfo: ["key": "value"])
        let error = DigiDocError.initializationFailed(errorDetail)

        let retrievedDetail = error.errorDetail

        #expect(errorDetail.message == retrievedDetail.message)
        #expect(errorDetail.code == retrievedDetail.code)
        #expect(retrievedDetail.userInfo == ["key": "value"])
    }

    @Test
    func errorDetail_successWithAlreadyInitializedFailedError() {
        let error = DigiDocError.alreadyInitialized

        let retrievedDetail = error.errorDetail

        #expect(retrievedDetail.message == "Libdigidocpp is already initialized")
        #expect(retrievedDetail.code == 0)
        #expect(retrievedDetail.userInfo == [:])
    }

    @Test
    func errorDetail_successWithContainerCreationFailedError() {
        let errorDetail = ErrorDetail(message: "Container creation failed", code: 123, userInfo: [:])
        let error = DigiDocError.containerCreationFailed(errorDetail)

        let retrievedDetail = error.errorDetail

        #expect(errorDetail.message == retrievedDetail.message)
        #expect(errorDetail.code == retrievedDetail.code)
        #expect(retrievedDetail.userInfo.isEmpty)
    }

    @Test
    func errorDetailDescription_successWithContainerOpeningFailedError() {
        let errorDetail = ErrorDetail(message: "An error occurred", code: 123, userInfo: ["reason": "test case"])
        let error = DigiDocError.containerOpeningFailed(errorDetail)

        let description = error.description

        #expect(description.contains("Error: An error occurred"))
        #expect(description.contains("Code: 123"))
        #expect(description.contains("Info: [\"reason\": \"test case\"]"))
    }

    @Test
    func errorDescription_successWithAddingFilesToContainerFailedError() {
        let errorDetail = ErrorDetail(message: "Error message for testing", code: 123, userInfo: [:])
        let error = DigiDocError.addingFilesToContainerFailed(errorDetail)

        let localizedDescription = error.errorDescription

        #expect(localizedDescription == "Error message for testing")
    }

    @Test
    func errorDescription_successWithContainerSavingFailedError() {
        let errorDetail = ErrorDetail(message: "Saving failed", code: 123, userInfo: [:])
        let error = DigiDocError.containerSavingFailed(errorDetail)

        let retrievedDetail = error.errorDetail

        #expect(errorDetail.message == retrievedDetail.message)
        #expect(errorDetail.code == retrievedDetail.code)
        #expect(retrievedDetail.userInfo.isEmpty)
    }
}
