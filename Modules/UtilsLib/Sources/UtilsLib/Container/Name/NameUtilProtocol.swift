import Foundation

/// @mockable
public protocol NameUtilProtocol: Sendable {
    func formatName(_ components: [String]) -> String
    func formatName(_ name: String) -> String
    func formatName(surname: String?, givenName: String?, identifier: String?) -> String
    func formatCompanyName(identifier: String?, serialNumber: String?) -> String
}
