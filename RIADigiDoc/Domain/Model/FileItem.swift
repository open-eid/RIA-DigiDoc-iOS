import Foundation

struct FileItem: Identifiable {
    let id = UUID()
    let name: String
    let url: URL
    let modifiedDate: Date
}
