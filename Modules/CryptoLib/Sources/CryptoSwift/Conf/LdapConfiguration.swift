/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

import Foundation
import CommonsLib
import UtilsLib

public struct LdapConfiguration: LdapConfigurationProtocol {
    @MainActor static public var ldapPersonURLS = [URL(string: "ldaps://esteid.ldap.sk.ee")]
    @MainActor static public var ldapCorpURL = URL(string: "ldaps://k3.ldap.sk.ee")

    private let fileManager: FileManagerProtocol

    public init(
        fileManager: FileManagerProtocol
    ) {
        self.fileManager = fileManager
    }

    @MainActor
    public func setLdapPersonURLS(_ urls: [URL?]) async throws {
        Self.ldapPersonURLS = urls
    }

    @MainActor
    public func setLdapCorpURL(_ url: URL?) async throws {
        Self.ldapCorpURL = url
    }

    public func ldapCertsPath() -> String? {
        return Directories
            .getLibraryDirectory(fileManager: fileManager)?
            .appending(path: Constants.Folder.LDAPCerts, directoryHint: .isDirectory)
            .appending(path: Constants.File.LDAPCertsPem)
            .resolvedPath
    }
}
