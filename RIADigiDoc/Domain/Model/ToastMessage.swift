// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import LibdigidocLibSwift

struct ToastMessage: Sendable, Equatable {
    let key: String
    let args: [String]

    init(key: String, args: [String] = []) {
        self.key = key
        self.args = args
    }
}

extension ToastMessage {
    static func containerOpeningFailed(fileName: String, error: Error) -> ToastMessage {
        guard let digiDocError = error as? DigiDocError, digiDocError.errorDetail.isNetworkError else {
            return ToastMessage(key: "Failed to open container", args: [fileName])
        }

        return ToastMessage(key: "No Internet connection")
    }
}
