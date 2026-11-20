// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public struct LdapSettings: Sendable, Equatable {
    public var personURLs: [URL]
    public var corpURL: URL?
    public var caCertificates: [Data]

    public init(personURLs: [URL] = [], corpURL: URL? = nil, caCertificates: [Data] = []) {
        self.personURLs = personURLs
        self.corpURL = corpURL
        self.caCertificates = caCertificates
    }
}
