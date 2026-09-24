// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

enum ConfigurationLoaderError: Error {
    case configurationNotFound
    case publicKeyNotFound
    case signatureNotFound
    case configurationVerificationFailed
    case configurationLoadFailed
}
