import Foundation

public struct DataFileWrapper: Sendable, Identifiable, Hashable {
    public var id: UUID = UUID()
    public var fileId: String
    public var fileName: String
    public var fileSize: Int
    public var mediaType: String
}
