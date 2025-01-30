import SwiftUI
import LibdigidocLibSwift

struct DataFilesListView: View {
    let dataFiles: [DataFileWrapper]

    var body: some View {
        List(dataFiles, id: \.self) { dataFile in
            Text(verbatim: dataFile.fileName)
        }
    }
}
