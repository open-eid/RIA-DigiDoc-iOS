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
        #expect(userInfo == errorDetail.userInfo as? [String: String])
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
        #expect(
            errorDetail.userInfo as? [String : String] == [
                "key": "value",
                NSLocalizedDescriptionKey: "Test NSError message"
            ]
        )
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
        #expect(errorDetail.userInfo as? [String : String] == [
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
