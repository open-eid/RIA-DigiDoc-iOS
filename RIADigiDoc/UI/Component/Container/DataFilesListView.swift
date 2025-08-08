import SwiftUI
import LibdigidocLibSwift

struct DataFilesListView: View {
    @AppTheme private var theme
    @AppTypography private var typography

    let dataFiles: [DataFileWrapper]
    let showRemoveFileButton: Bool

    let onSaveDataFileButtonClick: (DataFileWrapper) -> Void

    var body: some View {
        List(dataFiles, id: \.self) { dataFile in
            DataFilesView(
                onSaveDataFileButtonClick: onSaveDataFileButtonClick,
                dataFile: dataFile,
                showRemoveFileButton: showRemoveFileButton
            )
        }
        .listStyle(PlainListStyle())
    }
}

#Preview {
    DataFilesListView(
        dataFiles: [
            DataFileWrapper(
                id: UUID(),
                fileId: "1",
                fileName: "DataFile1.txt",
                fileSize: 123,
                mediaType: "text/plain"
            ),
            DataFileWrapper(
                id: UUID(),
                fileId: "2",
                fileName: "DataFile2.txt",
                fileSize: 456,
                mediaType: "text/plain"
            )
        ],
        showRemoveFileButton: true,
        onSaveDataFileButtonClick: { _ in }
    )
}
