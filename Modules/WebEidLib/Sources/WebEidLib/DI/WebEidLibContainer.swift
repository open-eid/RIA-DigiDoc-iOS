// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import FactoryKit

extension Container {
    public var webEidAuthService: Factory<WebEidAuthServiceProtocol> {
        self {
            WebEidAuthService()
        }
    }

    public var webEidSignService: Factory<WebEidSignServiceProtocol> {
        self {
            WebEidSignService()
        }
    }
}
