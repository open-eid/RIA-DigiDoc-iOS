import Foundation
import LibdigidocLibSwift
import CommonsLib

public struct MockDataFileWrapper {
    public static func mockDataFileWrapper(
        fileId: String = "1",
        fileName: String = "mockFile.txt",
        fileSize: Int = 1024,
        mediaType: String = Constants.MimeType.Default
    ) -> DataFileWrapper {
        DataFileWrapper(
            fileId: fileId,
            fileName: fileName,
            fileSize: fileSize,
            mediaType: mediaType
        )
    }
}
