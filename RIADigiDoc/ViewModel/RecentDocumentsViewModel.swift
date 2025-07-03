import Foundation
import FactoryKit
import OSLog
import CommonsLib

@MainActor
class RecentDocumentsViewModel: RecentDocumentsViewModelProtocol, ObservableObject {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "RecentDocumentsViewModel")

    @Published var isImporting = false
    @Published var files: [FileItem] = []
    @Published var searchText: String = ""
    @Published var folderURL: URL

    private let sharedContainerViewModel: SharedContainerViewModelProtocol

    private let fileManager: FileManagerProtocol

    init(
        sharedContainerViewModel: SharedContainerViewModelProtocol,
        folderURL: URL? = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first?.appendingPathComponent(
            Constants.Container.SignedContainerFolder,
            isDirectory: true
        ),
        fileManager: FileManagerProtocol
    ) {
        self.sharedContainerViewModel = sharedContainerViewModel
        if let folderURL = folderURL {
            self.folderURL = folderURL
        } else {
            self.folderURL = URL(fileURLWithPath: "")
        }
        self.fileManager = fileManager
    }

    var filteredFiles: [FileItem] {
        let sortedFiles = files.sorted { $0.modifiedDate > $1.modifiedDate }
        return sortedFiles.filter { file in
            CommonsLib.Constants.Container.ContainerExtensions.contains(file.url.pathExtension.lowercased()) &&
                (searchText.isEmpty || file.name.localizedCaseInsensitiveContains(searchText))
        }
    }

    func setChosenFiles(_ chosenFiles: Result<[URL], Error>) {
        sharedContainerViewModel.setFileOpeningResult(fileOpeningResult: chosenFiles)
    }

    func loadFiles() {
        do {
            let fileURLs = try fileManager.contentsOfDirectory(
                at: folderURL,
                includingPropertiesForKeys: [.contentModificationDateKey],
                options: .skipsHiddenFiles
            )
            files = fileURLs.compactMap { url in
                if let attributes = try? fileManager.attributesOfItem(atPath: url.path),
                   let modifiedDate = attributes[.modificationDate] as? Date {
                    if CommonsLib.Constants.Container.ContainerExtensions.contains(url.pathExtension.lowercased()) {
                        return FileItem(name: url.lastPathComponent, url: url, modifiedDate: modifiedDate)
                    }
                }
                return nil
            }
        } catch {
            files = []
            RecentDocumentsViewModel.logger.error("Unable to load files: \(error.localizedDescription)")
        }
    }

    func deleteFile(at offsets: IndexSet) {
        offsets.forEach { index in
            let file = filteredFiles[index]
            do {
                try fileManager.removeItem(at: file.url)
                files.removeAll { $0.url == file.url }
            } catch {
                RecentDocumentsViewModel.logger.error("Unable to delete file: \(error.localizedDescription)")
            }
        }
    }
}
