// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

public struct EncryptionServerInfo: Sendable {
    var uuid: String
    var name: String
    var fetchURL: String
    var postURL: String

    init(uuid: String = "", name: String = "", fetchURL: String = "", postURL: String = "") {
        self.uuid = uuid
        self.name = name
        self.fetchURL = fetchURL
        self.postURL = postURL
    }
}
