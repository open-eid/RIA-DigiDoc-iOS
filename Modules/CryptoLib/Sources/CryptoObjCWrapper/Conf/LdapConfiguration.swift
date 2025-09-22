import Foundation
import CommonsLib

public struct LdapConfiguration {
    @MainActor static public var ldapPersonURLS = [URL(string: "ldaps://esteid.ldap.sk.ee")]
    @MainActor static public var ldapCorpURL = URL(string: "ldaps://k3.ldap.sk.ee")

    private let fileManager: FileManagerProtocol

    public init(
        fileManager: FileManagerProtocol
    ) {
        self.fileManager = fileManager
    }

    public var ldapCertsPath: String? {
        self.fileManager.urls(
            for: .libraryDirectory,
            in: .userDomainMask
        )
        .first?
        .appendingPathComponent("LDAPCerts/ldapCerts.pem").path
    }
}
