import Foundation
import CommonsLib

/// @mockable
@MainActor
public protocol ShareViewModelProtocol: Sendable {
    @discardableResult
    func importFiles(_ items: [ImportedFileItem]) async -> Bool
    func cacheItem(
        itemIndex: Int,
        providerIndex: Int,
        items: [ImportedFileItem],
    ) async throws -> Bool
    func cacheFileForProvider(fileItem: ImportedFileItem) async throws -> Bool
    func convertNSDataToURL(data: Data) throws -> URL
    func cacheFileOnUrl(_ itemUrl: URL) async -> Bool
    func downloadFileFromUrl(_ itemUrl: URL) async -> Bool
}
