// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public struct URLResourceChecker: URLResourceCheckerProtocol {
    public init() {}

    public func checkResourceIsReachable(_ url: URL) throws -> Bool {
        try url.checkResourceIsReachable()
    }
}
