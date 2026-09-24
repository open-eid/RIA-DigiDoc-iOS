// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
    private static let appLinksHost = "id.eesti.ee"

    public static func isWebEidUri(_ url: URL) -> Bool {
        getOperation(from: url) != WebEidOperation.unknown
    }

    public static func getOperation(from url: URL) -> WebEidOperation {
        var operation: String?

        let scheme = url.scheme?.lowercased()
        let host = url.host?.lowercased()

        if scheme == customScheme {
            operation = host
        } else if scheme == "https", host == appLinksHost {
            operation = url.pathComponents.dropFirst().first
        } else {
            operation = WebEidOperation.unknown.rawValue
        }

        guard let operation else { return WebEidOperation.unknown }
        return WebEidOperation.fromOperation(operation)
    }

    public static func displayOrigin(_ origin: String) -> String {
        guard let components = URLComponents(string: origin),
              let scheme = components.scheme,
              let encodedHost = components.percentEncodedHost else {
            return origin.unicodeScalars
                .filter { !$0.properties.isBidiControl }
                .reduce(into: "") { $0.unicodeScalars.append($1) }
        }

        let portPart = components.port.map { ":\($0)" } ?? ""
        return "\(scheme)://\(encodedHost)\(portPart)"
    }
}
