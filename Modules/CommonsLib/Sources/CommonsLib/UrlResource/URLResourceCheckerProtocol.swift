// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

/// @mockable
public protocol URLResourceCheckerProtocol {
    func checkResourceIsReachable(_ url: URL) throws -> Bool
}
