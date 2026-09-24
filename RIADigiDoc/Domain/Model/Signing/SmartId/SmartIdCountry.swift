// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public enum SmartIdCountry: String, Sendable, Equatable, Identifiable, CaseIterable {
    case estonia = "Estonia"
    case latvia = "Latvia"
    case lithuania = "Lithuania"

    public var id: String { rawValue }
}
