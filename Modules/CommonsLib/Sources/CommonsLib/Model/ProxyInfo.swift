// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

public struct ProxyInfo: Sendable, Equatable {
    public var option: ProxySettingsOption
    public var host: String
    public var port: Int
    public var username: String
    public var password: String

    public init(
        option: ProxySettingsOption = .disabled,
        host: String = "",
        port: Int = 80,
        username: String = "",
        password: String = ""
    ) {
        self.option = option
        self.host = host
        self.port = port
        self.username = username
        self.password = password
    }
}
