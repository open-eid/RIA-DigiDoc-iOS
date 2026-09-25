// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

/// @mockable
public protocol MimeTypeDecoderProtocol: Sendable {
    func parse(xmlData: Data) async -> ContainerType
}
