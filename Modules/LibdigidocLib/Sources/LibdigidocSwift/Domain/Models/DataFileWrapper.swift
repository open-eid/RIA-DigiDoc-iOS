import Foundation

public struct DataFileWrapper: Sendable, Identifiable, Hashable {
    public var id: UUID = UUID()
    public var fileId: String
    public var fileName: String
    public var fileSize: Int
    public var mediaType: String

    public init(
        id: UUID = UUID(),
        fileId: String,
        fileName: String,
        fileSize: Int,
        mediaType: String
    ) {
        self.id = id
        self.fileId = fileId
        self.fileName = fileName
        self.fileSize = fileSize
        self.mediaType = mediaType
    }
}
