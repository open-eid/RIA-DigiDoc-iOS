/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

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
        #expect(retrievedDetail.userInfo as? [String: String] == ["key": "value"])
    }

    @Test
    func errorDetail_successWithAlreadyInitializedFailedError() {
        let error = DigiDocError.alreadyInitialized

        let retrievedDetail = error.errorDetail

        #expect(retrievedDetail.message == "Libdigidocpp is already initialized")
        #expect(retrievedDetail.code == 0)
        #expect(retrievedDetail.userInfo.isEmpty)
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
    func isNetworkError_trueWhenCodeIsLibdigidocppNetworkError() {
        let errorDetail = ErrorDetail(message: "Failed to create connection with host", code: 20)

        #expect(errorDetail.isNetworkError)
    }

    @Test
    func isNetworkError_falseWhenCodeIsGeneral() {
        let errorDetail = ErrorDetail(message: "Failed to send request to SiVa", code: 0)

        #expect(!errorDetail.isNetworkError)
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
