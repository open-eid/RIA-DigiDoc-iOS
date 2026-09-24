// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import CommonsLib
import UtilsLib

public actor LdapConfiguration: LdapConfigurationProtocol {
    public private(set) var ldapPersonURLS: [URL] = []
    public private(set) var ldapCorpURL: URL?

    private let fileManager: FileManagerProtocol

    public init(
        fileManager: FileManagerProtocol
    ) {
        self.fileManager = fileManager
    }

    public func getLdapPersonURLS() async -> [URL] {
        return self.ldapPersonURLS
    }

    public func getLdapCorpURL() async -> URL? {
        return self.ldapCorpURL
    }

    public func setLdapPersonURLS(_ urls: [URL]) async {
        self.ldapPersonURLS = urls
    }

    public func setLdapCorpURL(_ url: URL) async {
        self.ldapCorpURL = url
    }

    public func ldapCertsPath() async -> String? {
        return Directories
            .getLibraryDirectory(fileManager: fileManager)?
            .appending(path: Constants.Folder.LDAPCerts, directoryHint: .isDirectory)
            .appending(path: Constants.File.LDAPCertsPem)
            .resolvedPath
    }
}
