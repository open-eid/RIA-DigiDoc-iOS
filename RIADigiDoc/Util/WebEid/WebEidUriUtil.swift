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

public enum WebEidOperation: String, CaseIterable, Sendable {
    case auth
    case cert
    case sign
    case unknown

    public static func fromOperation(_ operation: String) -> WebEidOperation {
        Self.allCases.first { $0.rawValue == operation } ?? WebEidOperation.unknown
    }
}

public enum WebEidUriUtil {
    private static let customScheme = "web-eid-mobile"
    private static let appLinksHost = "riadigidoc.ee"

    public static func isWebEidUri(_ url: URL) -> Bool {
        getOperation(from: url) != WebEidOperation.unknown
    }

    public static func getOperation(from url: URL) -> WebEidOperation {
        var operation: String?

        #if DEBUG
        let isCustomSchemeMatch = url.scheme == customScheme
        #else
        let isCustomSchemeMatch = false
        #endif

        if isCustomSchemeMatch {
            operation = url.host
        } else if url.scheme == "https", url.host == appLinksHost {
            operation = url.pathComponents.dropFirst().first
        } else {
            operation = WebEidOperation.unknown.rawValue
        }
        

        guard let operation else { return WebEidOperation.unknown }
        return WebEidOperation.fromOperation(operation)
    }
}
