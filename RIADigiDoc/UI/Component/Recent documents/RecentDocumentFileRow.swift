import SwiftUI

struct RecentDocumentFileRow: View {
    let file: FileItem

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(file.name)
                    .font(.headline)
            }
        }
    }
}
