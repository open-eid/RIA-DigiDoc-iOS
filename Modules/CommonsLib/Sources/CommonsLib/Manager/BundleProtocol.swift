// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

/// @mockable
public protocol BundleProtocol: Sendable {
    func url(forResource name: String?, withExtension ext: String?) -> URL?
    func path(forResource name: String?, ofType ext: String?) -> String?
    var resourceURL: URL? { get }
}

extension Bundle: BundleProtocol {
}
