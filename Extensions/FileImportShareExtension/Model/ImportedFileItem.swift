import Foundation
import UniformTypeIdentifiers

public struct ImportedFileItem: Sendable {
    let fileUrl: URL
    let filename: String
    let data: Data
    let typeIdentifier: UTType
}
