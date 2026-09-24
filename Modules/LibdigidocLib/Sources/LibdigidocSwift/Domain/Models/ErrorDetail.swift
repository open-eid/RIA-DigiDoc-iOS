// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import LibdigidocLibObjC

public struct ErrorDetail: Sendable {
    public let message: String
    public let code: Int
    public let userInfo: [String: Sendable]

    public init(message: String = "", code: Int = 0, userInfo: [String: Sendable] = [:]) {
        self.message = message
        self.code = code
        self.userInfo = userInfo
    }

    init(nsError: NSError) {
        self.message = nsError.localizedDescription
        self.code = nsError.code
        self.userInfo = ErrorDetail.extractInfo(from: nsError)
    }

    init(nsError: NSError, extraInfo: [String: Sendable]) {
        self.message = nsError.localizedDescription
        self.code = nsError.code
        self.userInfo = ErrorDetail.extractInfo(from: nsError)
            .merging(extraInfo) { (_, combined) in combined }
    }

    public var description: String {
        return """
            Error: \(self.message)
            Code: \(self.code)
            Info: \(self.userInfo)
        """
    }

    private static func extractInfo(from error: NSError) -> [String: Sendable] {
        var dict: [String: Sendable] = [:]

        for (key, value) in error.userInfo {
            dict[key] = String(describing: value)
        }

        dict[NSLocalizedDescriptionKey] = error.localizedDescription

        if let failedFileCount = error.userInfo["failedFileCount"] as? Int, failedFileCount > 0 {
            dict["failedFileCount"] = failedFileCount
        }

        if let totalFileCount = error.userInfo["totalFileCount"] as? Int, totalFileCount > 0 {
            dict["totalFileCount"] = totalFileCount
        }

        if let causes = error.userInfo["causes"] as? [String: Any],
           let errors = causes["errors"] as? [NSError],
           let firstError = errors.first,
           let subCauses = firstError.userInfo["causes"] as? [String: Any],
           let file = subCauses["fileName"] as? String, !file.isEmpty {

            dict["fileName"] = file
        }

        if let causes = error.userInfo["causes"] as? [String: Any],
           let errors = causes["errors"] as? [NSError],
           let firstError = errors.first,
           let subCauses = firstError.userInfo["causes"] as? [String: Any],
           let exceptions = subCauses["exceptions"] as? [Any], !exceptions.isEmpty {

            dict["exceptions"] = exceptions.map { "\($0)" }
        }

        return dict
    }
}
