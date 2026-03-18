/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
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
        ] as [String : Any]
        
        let result = WebEidResponseUtil.createErrorPayload(
            code: code,
            message: message
        )

        #expect(result.count == expected.count)
    }
    
    @Test
    func createResponseURL_returnURL() async throws {
        let result = try WebEidResponseUtil.createResponseURL(
            responseUri: "https://riadigidoc.ee/auth",
            payload: ["test":"test"]
        )
        let expected =  "https://riadigidoc.ee/auth#eyJ0ZXN0IjoidGVzdCJ9"
        
        #expect(result.absoluteString == expected)
    }
}
