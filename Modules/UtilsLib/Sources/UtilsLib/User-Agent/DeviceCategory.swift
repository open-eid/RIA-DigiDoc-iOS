// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

enum DeviceCategory: String {
    case mobile
    case tablet

    init(modelIdentifier: String) {
        self = modelIdentifier.hasPrefix("ipad") ? .tablet : .mobile
    }

    var osName: String {
        switch self {
        case .mobile: "iOS"
        case .tablet: "iPadOS"
        }
    }
}
