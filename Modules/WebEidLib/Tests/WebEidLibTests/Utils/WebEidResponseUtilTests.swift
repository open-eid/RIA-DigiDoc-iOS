// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import Testing
import CommonsLib
import CommonsTestShared
import WebEidLibMocks
import Security

@testable import WebEidLib

struct WebEidResponseUtilTests {

    @Test
    func createErrorPayload_returnJSONObject() async throws {
        let code = WebEidErrorCode.ERR_WEBEID_MOBILE_INVALID_REQUEST
        let message = "Some error occured!"

        let expected = [
            "error": true,
            "code": String(describing: code),
            "message": message
        ] as [String: Any]

        let result = WebEidResponseUtil.createErrorPayload(
            code: code,
            message: message
        )

        #expect(result.count == expected.count)
    }

    @Test
    func createResponseURL_returnURL() async throws {
        let result = try WebEidResponseUtil.createResponseURL(
            responseUri: "https://id.eesti.ee/auth",
            payload: ["test": "test"]
        )
        let expected = "https://id.eesti.ee/auth#eyJ0ZXN0IjoidGVzdCJ9"

        #expect(result.absoluteString == expected)
    }
}
