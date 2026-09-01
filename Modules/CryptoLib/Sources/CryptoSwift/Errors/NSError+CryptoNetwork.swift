// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public extension NSError {
    // libcdoc NetworkBackend::NETWORK_ERROR
    var isCryptoNetworkError: Bool {
        return domain == "ee.ria.digidoc.CryptoLib" && code == -300
    }
}
